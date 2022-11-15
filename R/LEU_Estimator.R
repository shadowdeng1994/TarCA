#' Detection of lineage specific expression upregulation.
#'
#' @param PathToData A RData file including tmp.tree, tmp.ann and tmp.fileout.
#' @param Tree A tree file of class "phylo" with node labels (using node ID by default).
#' @param Ann A dataframe with TipLabel and TipAnn (tip labels on the tree file and corresponding cell annotations).
#' @param Fileout A path to output (e.g. tmp.RData).
#' @param ReturnNp Return the result or not (TRUE by default).
#'
#' @return A list containing Tree, Ann, BiasNode, FilterBiasNode, BiasFig, PureNode, PureNode2Organ and EffN. The estimated Np are store in EffN.
#'
#' @export
#'
#' @examples
#' library("TarCA")
#' load(system.file("Exemplar","Exemplar_LEU.RData",package = "TarCA"))
#' tmp.res <- LEU_Estimator(
#' Tree = ExemplarData_2$Tree,
#' Ann = ExemplarData_2$Ann,
#' Fileout = NULL,
#' ReturnNp = TRUE
#' )

LEU_Estimator <- function(PathToData=NULL,Tree=NULL,Ann=NULL,Fileout=NULL,ReturnNp=TRUE){

  #### Load in data
  if(!is.null(PathToData)){
    load(PathToData,verbose=T)
  }else if(!is.null(Tree) & !is.null(Ann)){
    tmp.tree <- Tree
    tmp.ann <- Ann
    tmp.fileout <- Fileout
  }else{
    message("**** Require either RData or tree file. Quit...")
    return()
  }

  #### Check input data
  message("**** 1. Check input data.")
  tmp.tree <- fun.CheckInput(tmp.tree,tmp.ann,tmp.fileout)
  if(is.null(tmp.tree)){ return() }

  #### Get treedata file
  message("**** 2. Get BiasNode file.")
  tmp.BiasNode <- fun.GetBiasNode(tmp.tree,tmp.ann)

  #### Get node2tip file
  message("**** 3. Filter BiasNode.")
  if(nrow(tmp.BiasNode)>0){
    tmp.FilterBiasNode <- fun.FilterBiasNode(tmp.BiasNode,tmp.tree)
  }else{
    tmp.FilterBiasNode <- data.frame()
  }

  #### Get node2tip file
  message("**** 4. Plot BiasNode.")
  tmp.BiasFig <- fun.PlotBiasExpre(tmp.tree,tmp.ann,tmp.FilterBiasNode)

  #### Get pureNode file
  message("**** 5. Get pureNode file.")
  if(nrow(tmp.FilterBiasNode)>0){
    tmp.pureNode <- fun.GetPureNodeFromBias(tmp.FilterBiasNode,tmp.tree)
  }else{
    tmp.pureNode <- data.frame()
  }

  #### Get pureNode2organ
  message("**** 6. Get pureNode2organ file.")
  if(nrow(tmp.FilterBiasNode)>0){
    tmp.pureNode2organ <- fun.GetPureNode2Organ(tmp.pureNode,tmp.ann)
  }else{
    tmp.pureNode2organ <- tmp.ann %>% group_by(Parent=TipLabel,TipAnn) %>% summarise(Count=n())
  }

  #### Get CladeSizeDetail
  message("**** 7. Get CladeSizeDetail file.")
  tmp.CladeSizeDetial <- fun.GetCladeSizeDetail(tmp.pureNode2organ)

  #### Get Np
  #message("**** 8. Get Np file.")
  tmp.EffN <- left_join(tmp.CladeSizeDetial,fun.GetEffN(tmp.pureNode2organ),by="TipAnn")

  tmp.out <- list()
  tmp.out[["Tree"]] <- tmp.tree
  tmp.out[["Ann"]] <- tmp.ann
  tmp.out[["BiasNode"]] <- tmp.BiasNode
  tmp.out[["FilterBiasNode"]] <- tmp.FilterBiasNode
  tmp.out[["BiasFig"]] <- tmp.BiasFig
  tmp.out[["PureNode"]] <- tmp.pureNode
  tmp.out[["PureNode2Organ"]] <- tmp.pureNode2organ
  tmp.out[["EffN"]] <- tmp.EffN

  Result.EffN <- tmp.out

  if(!is.null(tmp.fileout)){ save(Result.EffN,file=tmp.fileout) }

  if(ReturnNp){ return(tmp.out) }

  message("**** Finish.")
}
