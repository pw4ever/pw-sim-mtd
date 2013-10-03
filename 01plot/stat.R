#! /usr/bin/env Rscript
require(ggplot2)

args <- commandArgs (trailingOnly=TRUE)
file.name.root <- args [1]

gen.file.name <- function (suffix) { paste(file.name.root, suffix, sep="") }

## names (data)
## [1] "node"                    "attacker.budget"        
## [3] "defender.init.asset"     "time"                   
## [5] "defender.type"           "defender.survived.asset"

data <- read.table(file=gen.file.name(".txt"), header=TRUE)

defender.survived.asset.max <- aggregate (data.frame (defender.survived.asset.max=data$defender.survived.asset),
                                          by=list (node=data$node, attacker.budget=data$attacker.budget, defender.init.asset=data$defender.init.asset, time=data$time, defender.type=data$defender.type),
                                          FUN=max)

defender.survived.asset.upper.quantile <- aggregate (data.frame (defender.survived.asset.upper.quantile=data$defender.survived.asset),
                                                     by=list (node=data$node, attacker.budget=data$attacker.budget, defender.init.asset=data$defender.init.asset, time=data$time, defender.type=data$defender.type),
                                                     FUN=function (x) {quantile (x, 0.75)})

defender.survived.asset.median <- aggregate (data.frame (defender.survived.asset.median=data$defender.survived.asset),
                                             by=list (node=data$node, attacker.budget=data$attacker.budget, defender.init.asset=data$defender.init.asset, time=data$time, defender.type=data$defender.type),
                                             FUN=median)

defender.survived.asset.lower.quantile <- aggregate (data.frame (defender.survived.asset.lower.quantile=data$defender.survived.asset),
                                                     by=list (node=data$node, attacker.budget=data$attacker.budget, defender.init.asset=data$defender.init.asset, time=data$time, defender.type=data$defender.type),
                                                     FUN=function (x) {quantile (x, 0.25)})

defender.survived.asset.min <- aggregate (data.frame (defender.survived.asset.min=data$defender.survived.asset),
                                          by=list (node=data$node, attacker.budget=data$attacker.budget, defender.init.asset=data$defender.init.asset, time=data$time, defender.type=data$defender.type),
                                          FUN=min)

defender.survived.asset.stat <- defender.survived.asset.median

defender.survived.asset.stat <- merge(
    defender.survived.asset.stat,
    defender.survived.asset.max
    )
defender.survived.asset.stat <- merge(
    defender.survived.asset.stat,
    defender.survived.asset.min
    )

defender.survived.asset.stat <- merge(
    defender.survived.asset.stat,
    defender.survived.asset.upper.quantile
    )
defender.survived.asset.stat <- merge(
    defender.survived.asset.stat,
    defender.survived.asset.lower.quantile
    )

save (defender.survived.asset.stat, file=gen.file.name (".stat"))

