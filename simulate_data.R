########################################################################
#### Benchmark of differential abundance methods for clustered data ####
########################################################################

###############################
#### Libraries & functions ####
###############################

library(tidyverse)
library(phyloseq)
library(microbiome)
library(hablar)

##########################
#### Data preparation ####
##########################

source("functions.R")

dat <- readRDS("Data/phyl_list.RDS")

data  <- dat %>% prepare_DA_data(tax="Family")

data %>% 
  dplyr::select(-c("ID","N","status")) %>%
  mutate(cluster = case_when(author == author.names[[1]] ~ 1,
                             author == author.names[[2]] ~ 2,
                             author == author.names[[3]] ~ 3,
                             author == author.names[[4]] ~ 4,
                             author == author.names[[5]] ~ 5,
                             author == author.names[[6]] ~ 6,
                             author == author.names[[7]] ~ 7,
                             author == author.names[[8]] ~ 8,
                             author == author.names[[9]] ~ 9),
                             .keep="unused",.after='author') -> df

colnames(df)[-1] <- paste0("Bac",1:(ncol(df)-1))



create_Dataset <- function(df,                   # Dataset to resample from
                           c_size = 60,          # Number of observations per cluster
                           replacement = T,      # Resampling with replacement - standard is true, to allow for all sample sizes
                           group_balance = .5,   # Balance of group sizes for which the effect is induced
                           
                           effect_size = 1.2,     # Effect size to simulate
                           #n_otu = 200,          # Number of total OTUs
                           n_effect = 10         # Number of OTUs with differential abundance effect
                           
                           ## Possible additional parameters ##
                           # effect_sd = .1 # between-study heterogeneity of effect
                           # sigma = covariancce between random intercept and slope
) {
  
  
  ### Prepare clustered data set by resampling from original data - keeping clustering intact
  set <- df %>% 
    group_by(cluster) %>%
    sample_n(c_size,replace = replacement) %>%
    select(where(~ !is.numeric(.) || sum(.) != 0)) %>%
    ungroup() %>% 
    mutate(ID = 1:nrow(.),.before="cluster")
  
  set$group <- rep(rep(c(0,1),each=c_size*.5),length(unique(set$cluster)))
  
  ### Select OTUs for spike-in effect
  otus <- setdiff(colnames(set),c("cluster","ID","group"))
  selected_otus <- otus[sample(1:length(otus),size = n_effect,replace = F)]
  
  
  ### induce effect
  
  induceEffect <- function(x) round(x*effect_size,0)
  
  ## Select OTUs
  effect_set <- as.data.frame(set[,c("ID","cluster","group",selected_otus)])
  
  ## Induce differential abundance effect
  effect_set[effect_set$group==1,selected_otus] <- round(effect_set[effect_set$group==1,selected_otus] * effect_size,0)
  
  ## Rename OTUs including effects
  colnames(effect_set)[-c(1:3)] <- paste0("Sim",1:n_effect)
  
  out_df <- set %>%
    left_join(effect_set)
  
  out <- list("df"=out_df)
  
  return(out)
  
  
}

c_size <- c(20,40,60,100,200,500)
group_balance <- c(.25,.5,.75)
effect_size <- c(1.2,1.5,1.8,2) 
n_effect <- c(5,10,15,20)


szenarios <- expand_grid(c_size,group_balance,effect_size,n_effect)



datasets <- apply(szenarios,1, function(x) create_Dataset(df=df,
                                            c_size=x[1],
                                            group_balance = x[2],
                                            effect_size = x[3],
                                            n_effect = x[4]),simplify = F)


