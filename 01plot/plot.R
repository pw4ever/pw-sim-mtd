#! /usr/bin/env Rscript
require(ggplot2)

args <- commandArgs (trailingOnly=TRUE)
file.name.root <- args [1]

gen.file.name <- function (suffix) { paste(file.name.root, suffix, sep="") }

load (file=gen.file.name (".stat"))



g <- ggplot (data=defender.survived.asset.stat,
             aes (x=time,
                 #fill=defender.type,
                 linetype=defender.type,
                 colour=defender.type
                 )
    ) +
    xlab ("time") +
    ylab ("asset survival (%)") +

    geom_line (
        aes(
            y=defender.survived.asset.median/defender.init.asset*100
            ),
        alpha=1,
        size=0.5
        ) +

    geom_line (
        aes(
            y=defender.survived.asset.upper.quantile/defender.init.asset*100
            ),
        alpha=0.5,
        size=0.3
        ) +     
    geom_line (
        aes(
            y=defender.survived.asset.lower.quantile/defender.init.asset*100
            ),
        alpha=0.5,
        size=0.3
        ) +    

    geom_line (
        aes(
            y=defender.survived.asset.max/defender.init.asset*100
            ),
        alpha=0.35,
        size=0.3
        ) +     
    geom_line (
        aes(
            y=defender.survived.asset.min/defender.init.asset*100
            ),
        alpha=0.35,
        size=0.3
        ) +

    facet_grid (attacker.budget ~ defender.init.asset) +
    theme_bw () +
    theme (legend.title=element_blank ())

#print (g)

ggsave (filename=gen.file.name (".pdf"), width=10, height=8)
    

