# Microbiome simulation study

## Microbiome data generating process
![16s gene](16s_var_region.png)

<img src="https://www.researchgate.net/profile/Yuanqiang_Zou/publication/330862392/figure/fig1/AS:728652664811520@1550735741507/Phylogenetic-tree-of-1-520-isolated-gut-bacteria-based-on-whole-genome-sequences-The.png" alt="phylogeny" width="600"/>

### Data characteristics


| Bifidobacterium | Adlercreutzia | Collinsella | Denitrobacterium | Eggerthella |      N |
|----------------:|--------------:|------------:|-----------------:|------------:|-------:|
|               0 |         11987 |           0 |                0 |         177 | 617780 |
|              73 |             4 |         335 |                0 |          12 |  17408 |
|             104 |             0 |        1387 |                0 |          21 | 111836 |
|            2716 |             0 |         574 |              125 |          12 |  63750 |
|              53 |          3971 |        3880 |                8 |           0 | 406916 |
|             815 |           462 |         951 |              176 |          79 | 176121 |
|             145 |           120 |         311 |               53 |          11 |  66501 |
|               0 |             0 |         416 |                0 |          76 |  47556 |
|              73 |             0 |           0 |                0 |         167 |  58871 |
|              17 |             6 |           0 |                0 |           0 |  60645 |

Table 1: Example excerpt from microbiome dataset


- High-dimensional
    - up to several thousand species
    - increasing dimensionality with lower taxonomic ranks
- Compositional
    - sequences always sum up to a constant (sequencing depth) / only relative
    - sequencing depth is variable between samples
    - effects of compositonality may be higher on higher ranks (diminished with very many categories)
- Multivariate
    - complex (biological) interactions between taxa
    - especially temporal interaction (Lotka-Volterra, etc.)
- zero inflated
    - substantial amount of zeros in the Data
    - ![sparsity](sparsity_mat.jpg)
    - different types of zeros
        - technical due to non-detection
        - true due to absence in the biological sample
- Unequal sequencing depth
    - certainty about proportions varies between samples
    - zero-inflation relared to sequencing depth - higher sequencing depth = higher probability to cover all present taxa
- Over-dispersed
    - related to parametric models for count Data
    - Mean-Variance association in Poisson models usually not met in microbiome data -> therefore, negative binomial
    - Multivariate extension in terms of dirichlet multinomial models assume constant scale parameter for over-dispersion, which is likely not met (highly variable over-dispersion per taxa)

## Aims and challenges of the simulation study

### Current practice
Most currently available simulation studies are part of the original publication of one particular method. Commonly, these publication use the model that is subject of benchmarking also to generate simulated data that is used for benchmarking, which is inherently favoring the proposed methods. However, often *real* data is much more complex and models are miss-specified due to missing information on possible confounders and other effects. These simulation studies usually do not investigate the sensitivity more realistic data structures. On the other hand, existing independent simulation studies<sub>1</sub> avoided the use of parametric models by using resampling strategies on real microbiome data and inducing artificial effects either as additive or multiplicative _spikes_ in single taxa. Performance is then measured as the proportion of retrieval of these effects in a series of simulated datasets. The advantage of pure "retrieval" performance is, that it can be applied to a diverse set of parametric and non-parametric methods that provide different types of estimates and parameters. Although these studies are well designed, the approach is providing a rather limited benchmark. At first, simple univariate spikes may not represent how true biological effects would emerge in microbiome data and implicitly favor univariate methods (as the effects are univariate by design). Further, these effects are rather simple and cannot not easily be extended to more complex settings, such as clustered observations. Further, a single performance measure is very limited in the information that it provides regarding the behavior of single methods. Commonly used performance measures (coverage, bias, empirical SE, among others) cannot be applied.
Finally, to my knowledge, no currently available simulation makes a clear distinction between different taxonomic ranks. As almost all data characteristics are related to the taxonomic rank, it is unlikely that there is one perfect method for all taxonomic ranks. Therefore, benchmarking should be performed separately to investigate possible differences in methods performance among different ranks.

### Aims for this simulation study

Conceptual:
- The results should be a paper that may serve as a direct guidance paper for (applied) researchers

Technical:
- __Neutral__ benchmark of methods design to test differential abundance
-  Simulation of __clustered / longitudinal effects__
- Evaluate the influence of / robustness against data characteristics
- Benchmark on different taxonomic ranks

## Setup of the simulation study

### Data generating mechanism
The is currently no consensus about which parametric model perfectly resembles the data generating process of microbiome data. Although many researchers opt for the Dirichlet multinomial model as a sensible choice, there are some drawbacks of this model which may limit the applicability to microbiome data. First, the multinomial components are strictly negatively correlated due to the compositional nature. However, due to the biological relations in microbiome data, one would expect specific features to be correlated. In addition, the Dirichlet multinomial - as the over-dispersed generalization to the multinomial distribution - assumes equal over-dispersion among all features<sub>2</sub>, which can easily be inspected in the dataset at hand and is mostly not the case in microbiome data.
Further, even when the Dirichlet multinomial model would perfectly resemble the data generating process, the effects in microbiome data are highly complex and a miss-specification of the true data generating model is likely. Therefore, generating data from a full specified Dirichlet multinomial model would over-estimate the performance of methods in most real microbiome datasets.

### Semi-parametric simulation
#### Resampling
A sensible approach to ensure realistic data is resampling from true microbiome data. Resampling comes with several challenges compared to classical parametric simulations of data. First, resampled datasets will contain "noise" due to sampling variability which will decreasing with increasing sample size. However, as small sample sizes are common in microbiome studies, they should be subject of this benchmark as well. Therefore, sampling variablity needs to be taken into account when benchmarking methods based on resampled datsets. Secondly, resampling alone does not model the effects needed to benchmark the methods for differential abundance testing. As introduced, a common approach is to add univariate __spikes__ into selected features. However, in order to be able to model more complex situation, a different approach is needed.

#### Parametric model for differential abundance effects
Once a _realistic_ dataset is obtained from resampling, effects can be induced by a parametric model "on top" of the resampled dataset. Opting for this trade-off enables us to model complex effects.


# Literature
<sub>1</sub>Thorsen, Jonathan, Asker Brejnrod, Martin Mortensen, Morten A. Rasmussen, Jakob Stokholm, Waleed Abu Al-Soud, Søren Sørensen, Hans Bisgaard, und Johannes Waage. „Large-Scale Benchmarking Reveals False Discoveries and Count Transformation Sensitivity in 16S RRNA Gene Amplicon Data Analysis Methods Used in Microbiome Studies“. Microbiome 4, Nr. 1 (25. November 2016): 62. https://doi.org/10.1186/s40168-016-0208-8.

<sub>2</sub>Townes, F. William. „Review of Probability Distributions for Modeling Count Data“. ArXiv:2001.04343 [Stat], 10. Januar 2020. http://arxiv.org/abs/2001.04343.
