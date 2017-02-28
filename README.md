# hip-scaling-with-david
dude....its hip scaling

The data are in 'mass_eff_3.csv'
mass and eff are olivias estimates (undergrad = less experience)
mass2 and eff2 are peters estimates (Just finished Phd, studies dinosaurs, should know about joint locations)
Note mass and mass2 are from a second independent source and should be identical. 


Ok, so here are my ideas

First i want to reproduce the boxplot we had in your paper, i.e. get the average slope among all whole class, then means for orders, families, genera. If the slope decreases then its as we expect, though the phylogenetic correction seems to suggest it increases. 
(note: i just checked, almost no genera, and very few families have sample sizes greater than 4, so this method might not work)

Second i want to try to repeat this analysis but instead using each mode of the phylogeny as an independent point. We should know node age (from the phylo), and we get all subsequent tips below this node and calculate the slope. Repeat for each node, and we should be able to produce a scatter plot. Node age vs slope. 

Finally, i want to figure out whether being upright responds faster to becoming larger than to becoming smaller (make sense?) 

So i want to identify a series of nodes where the (mean / predicted ancestral) body size has increased over time, and also those that have decreased over time. Plot node age and mass, get slope, compare to node age vs eff slope. Do this for series where body size increases vs decreases, to see if species, once upright resist returning to crouched posture? 



