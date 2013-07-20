package edu.pdx.cs.data

import org.apache.commons.logging.LogFactory
import org.biojavax.bio.seq.RichSequence
import webapp.GCPercentage

/**
 * Created with IntelliJ IDEA.
 * User: Laura
 * Date: 7/6/13
 * Time: 10:04 AM
 * To change this template use File | Settings | File Templates.
 */
class GCPercentageProcessor implements Processor {

    private static final log = LogFactory.getLog(this)

    @Override
    void process(RichSequence richSequence) {
        def organismId = Integer.valueOf(richSequence.identifier)
        def String gc
        def sequence = richSequence.seqString()
        def g = sequence.count('g')
        def c = sequence.count('c')
        def num = new BigDecimal(g+c)
        def denom = new BigDecimal(sequence.length())
        def scale = 10

        def temp = num.divide(denom, scale, BigDecimal.ROUND_HALF_UP)
        gc = temp.movePointRight(2).toString() // multiplying by 100 added 2 0s at the end, implying more
                                                    // exactness than was there

        try {
            new GCPercentage(
                    organismId: organismId,
                    gcPercentage: gc
            ).save(flush:true)
        } catch (Exception e) {
            log.warn("Error persisting GCPercentage object: ", e)
        }
    }
}