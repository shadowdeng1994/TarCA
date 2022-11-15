# TarCA-Private

The method, termed as targeting coalescent analysis (TCA), computes for all cells of a tissue the average coalescent rate at the monophyletic clades of the target tissue, the inverse of which then measures the progenitor number of the tissue.

## Install

```
install.packages('devtools')
devtools::install_github('shadowdeng1994/TarCA')
```

## Usage
```
library("TarCA")
```
### Estimate Np with cell phylogenetic tree
Load exemplar dataset for Np_estimator. tmp.tree
```
load(system.file("Exemplar","Exemplar_TCA.RData",package = "TarCA"))
tmp.tree <- ExemplarData_1$Tree
tmp.ann <- ExemplarData_1$Ann
```

```
tmp.res <- Np_Estimator(
  Tree = ExemplarData_1$Tree,
  Ann = ExemplarData_1$Ann,
  Fileout = NULL,
  ReturnNp = TRUE
)
```

## Contributing

PRs accepted.

## License

MIT © Richard McRichface
