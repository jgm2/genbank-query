<%--
  Created by IntelliJ IDEA.
  Author: Joseph Lee <josel@pdx.edu>
  Date: 7/17/13
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>GenBank-Query</title>
    <meta name="layout" content="main"/>

    <link rel="stylesheet" href="${resource(dir: 'css', file: 'main.css')}" type="text/css">

    <flot:resources plugins="['pie']" includeJQueryLib="false" includeExCanvasLib="false"/>
    <gvisualization:apiImport />

</head>
<body>

<g:if test="${organisms.size() > 0}">

    <%-- Codon Distribution --%>
    <div id="codon-dist">
        <div class="row">
        <h2>Codon Distribution</h2>

        <%-- Main codon dist chart, all sequences with averages --%>
        <%
            def codonDist = codonDistribution
            def columnHeaders
            def options = [
                    vAxis: [minValue: 0],
                    hAxis: [slantedTextAngle: 90,
                            textStyle: [fontSize: 8]
                    ],
                    chartArea: [top: 40, bottom: 0, left: 40, right: 100]
            ]
            if (organisms.size() == 1) {
                columnHeaders = [
                        ['string', 'Sequence'],
                        ['number', organisms[0].scientificName],
                        ['number', 'Average']
                ]
                options.put("series", [1: [type: 'line']])
            }
            else if (organisms.size() == 2) {
                columnHeaders = [
                        ['string', 'Sequence'],
                        ['number', organisms[0].scientificName],
                        ['number', organisms[1].scientificName],
                        ['number', 'Mean (' + organisms[0].scientificName + ')'],
                        ['number', 'Mean (' + organisms[1].scientificName + ')'],
                ]
                options.put("series", [2: [type: 'line'], 3: [type: 'line']])
            }

        %>
        <div id="codonDist"></div>
        <gvisualization:comboCoreChart columns="${columnHeaders}" data="${codonDist}"
                                       elementId="${"codonDist"}"
                                       vAxis="${new Expando(options.vAxis)}" hAxis="${new Expando(options.hAxis)}"
                                       chartArea="${new Expando(options.chartArea)}"
                                       legend="${'out'}" height="${400}" width="${938}"
                                       seriesType="${"bars"}" series="${new Expando(options.series)}"
                                       titleTextStyle="${new Expando(titleTextStyle)}" />


        </div>

        <div class="row">
        <%-- Codon Distribution By Amino --%>
        <h2>Codon Distribution by Amino Acid</h2>
        <%
            // Set options
            def codonDistByAmino = codonDistributionByAmino
            def textStyle = [fontSize: 10]
            def titleTextStyle = [fontSize: 13]
            options = [
                    vAxis: [maxValue: 1, minValue: 0, textStyle: textStyle],
                    hAxis: [textStyle: textStyle],
                    legend: [position: 'none'],
                    chartArea: [top: 40, bottom: 0, left: 40, right: 0],
                    colors: ['blue', 'red']
            ]
            def rowCounts = [2, 3, 2, 2, 3, 3, 4, 2]    // Graph row lengths
            def c = 0
            def i = 0
            def codonList = codonDistByAmino.collectNested { it.name }
            def amino = null

            if (organisms.size() == 1) {
                columnHeaders = [['string', 'Codon'], ['number', 'Distribution']]
            }
            else {
                columnHeaders = [['string', 'Codon'], ['number', 'Distribution1'], ['number', 'Distribution2']]
            }
        %>
        <g:if test="${organisms.size() > 1}">
            <%-- legend --%>
            <div>
                <div class="legendColor" style="background-color: ${options.colors[0]}"></div>
                ${organisms[0].scientificName}
            </div>
            <div>
                <div class="legendColor" style="background-color: ${options.colors[1]}"></div>
                ${organisms[1].scientificName}
            </div>
        </g:if>

        <g:each in="${rowCounts}" var="r">
            <div class="row">
                <% c = 0 %>
                <g:while test="${c < r}">
                    <%
                        amino = codonDistByAmino[i]
                    %>
                    <div class="dist-graph" id="${"amino" + i.toString()}"></div>
                    <gvisualization:columnCoreChart columns="${columnHeaders}" data="${amino.values}"
                        elementId="${"amino" + i.toString()}" title="${amino.name}" vAxis="${new Expando(options.vAxis)}"
                        legend="${'none'}" height="${200}" width="${40 + amino.values.size() * 80}"
                        colors="${options.colors}"
                        titleTextStyle="${new Expando(titleTextStyle)}"
                        chartArea="${new Expando(options.chartArea)}" />
                    <%
                        c = c + 1
                        i = i + 1
                    %>
                </g:while>
            </div>
        </g:each>
        </div>
    </div>

    <g:if test="${opt && opt.contains("GC")}">
        <%-- GC Percentage --%>
        <div id="gc" class="row">
            <h2>GC Percentages</h2>
            <div id="gcPie0" class="piechart float-left"></div>
            <div id="gcText">
                <%
                    c = 0
                    def percentage, split
                %>
                <g:each in="${organisms}" var="organism">
                    <%
                        percentage = organism.gcPercentage
                        if (percentage.length() > 5) {
                            split = percentage.split(/\./)
                            if (split[1].size() > 2 && new Integer(split[1][2]) >= 5) {
                                percentage = split[0] + "." + split[1][0] + (new Integer(split[1][1]) + 1).toString()
                            }
                            else {
                                percentage = split[0] + "." + split[1][0..1]
                            }
                        }
                    %>
                    <div id="${"gcPerc" + c.toString()}">
                        ${organism.scientificName}: ${percentage}%
                    </div>
                    <% c = c + 1 %>
                </g:each>
            </div>
            <div id="gcPie1" class="piechart float-right"></div>
            <% c = 0 %>
            <g:each in="${organisms}" var="organism">
                <%
                    def gcp = new BigDecimal(organism.gcPercentage)
                    def gcData = [['GC', gcp], ['AT', 100 - gcp]]
                    columnHeaders = [['string', 'Codon'], ['number', 'Percentage']]
                    options = [
                            legend: [position: 'none'],
                            pieSliceText: 'label',
                            pieSliceTextStyle: [fontSize: 12]
                    ]
                %>
                <gvisualization:pieCoreChart elementId="${"gcPie" + c.toString()}"
                    columns="${columnHeaders}" data="${gcData}"
                    pieSliceText="${"label"}" pieSliceTextStyle="${new Expando(options.pieSliceTextStyle)}"
                    width="${200}" height="${200}" legend="${"none"}"/>
                <% c = c + 1 %>
            </g:each>
        </div>
    </g:if>

</g:if>

<g:if test="${(organisms.size() == 2) && codonDifference}">
    <%-- Codon Difference Analysis --%>
    <div class="row">
        <h2>Codon Difference</h2>
        <%
            columnHeaders = [['string', 'Sequence'], ['number', 'Difference'], ['number', 'Average']]
            options = [
                    vAxis: [maxValue: 1, minValue: 0],
                    hAxis: [slantedTextAngle: 90,
                            textStyle: [fontSize: 8]
                    ],
                    chartArea: [top: 40, bottom: 0, left: 40, right: 100],
                    series: [1: [type: 'line']]
            ]
        %>
        <div id="codonDifference"></div>
        <gvisualization:comboCoreChart columns="${columnHeaders}" data="${codonDifference}"
            elementId="${"codonDifference"}"
            vAxis="${new Expando(options.vAxis)}" hAxis="${new Expando(options.hAxis)}"
            chartArea="${new Expando(options.chartArea)}"
            legend="${'in'}" height="${400}" width="${938}"
            seriesType="${"bars"}" series="${new Expando(options.series)}"
            titleTextStyle="${new Expando(titleTextStyle)}" />
    </div>
</g:if>

<g:if test="${(organisms.size() == 2)  && opt && opt.contains("RSCU")}">
    <%-- RSCU Codon Analysis --%>
    <div class="row">
        <h2>RSCU Analysis</h2>
        <%
            def keys = organisms[0].rscuCodonDistribution.keySet()
            def rscuData = []
            for (codon in keys) {
                rscuData.push([
                        organisms[0].rscuCodonDistribution[codon],
                        organisms[1].rscuCodonDistribution[codon] ])
            }
        %>
        <g:javascript>
            var rscuFlotData = [
                {
                    data: ${rscuData},
                    points: {
                        radius: 4,
                        show: true,
                        fill: true,
                        fillColor: '#058DC7'
                    },
                    lines: { show: false },
                    color: '#058DC7'
                },
                {
                    data: [
                        [0, ${rscuComp.trendlineYIntercept}],
                        [1, ${rscuComp.trendlineSlope + rscuComp.trendlineYIntercept}]
                    ],
                    lines: { show: true },
                    fill: true,
                    color: '#cc2222'
                }
            ];
            var rscuFlotOptions = {
                xaxis: { min: 0, max: 1 },
                yaxis: { min: 0, max: 1 },
                shadowSize: 0,
                grid: {
                    borderWidth: 0
                }
            };
        </g:javascript>
        <flot:plot id="container-flot" style="width: 500px; height: 500px;"
            data="rscuFlotData" options="rscuFlotOptions"/>
        <%-- TODO: Add axis labels with organism names --%>
    </div>
</g:if>

<g:if test="${organisms.size() > 0}">
    <hr/>
</g:if>

</body>
</html>
