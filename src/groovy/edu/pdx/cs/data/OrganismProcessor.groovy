package edu.pdx.cs.data

import org.biojavax.bio.seq.RichSequence
import webapp.Organism

/**
 * Created with IntelliJ IDEA.
 * User: Ryan
 * Date: 6/30/13
 * Time: 3:18 PM
 * To change this template use File | Settings | File Templates.
 */
class OrganismProcessor implements Processor {

    @Override
    void process(RichSequence richSequence) {
        def organismId = Integer.valueOf(richSequence.identifier)
        def scientificName = richSequence.taxon.getNames("scientific name").first()
        def taxonomyId = richSequence.taxon.NCBITaxID

        new Organism(
                organismId: organismId,
                scientificName: scientificName,
                taxonomyId: taxonomyId
        ).save()
    }
}
