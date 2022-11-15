#' Estimate Np using cell phylogeny for each sub-population.
#'
#' @param PathToData A RData file including tmp.tree, tmp.ann and tmp.fileout.
#' @param Tree A tree file of class "phylo" with node labels (using node ID by default).
#' @param Ann A dataframe with TipLabel and TipAnn (tip labels on the tree file and corresponding cell annotations).
#' @param Fileout A path to output (e.g. tmp.RData).
#' @param ReturnNp Return the result or not (TRUE by default).
#'
#' @return A list containing Tree, Ann, PureNode, PureNode2Organ and EffN. The estimated Np are store in EffN.
#'
#' @export
#'
#' @examples
#' library("TarCA")
#' load(system.file("Exemplar","Exemplar_TCA.RData",package = "TarCA"))
#' tmp.res <- Np_Estimator(
#' Tree = ExemplarData_1$Tree,
#' Ann = ExemplarData_1$Ann,
#' Fileout = NULL,
#' ReturnNp = TRUE
#' )

Np_Estimator <- function(PathToData=NULL,Tree=NULL,Ann=NULL,Fileout=NULL,ReturnNp=TRUE){
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
    message("**** 2. Get treedata file.")
    tmp.treedata <- fun.GetTreeData(tmp.tree)

    #### Get node2tip file
    message("**** 3. Get node2tip file.")
    tmp.node2tip <- fun.GetNode2Tip(tmp.tree,tmp.treedata)

    #### Get pureNode file
    message("**** 4. Get pureNode file.")
    tmp.pureNode <- fun.GetPureNode(tmp.treedata,tmp.ann,tmp.node2tip)

    #### Get pureNode2organ
    message("**** 5. Get pureNode2organ file.")
    tmp.pureNode2organ <- fun.GetPureNode2Organ(tmp.pureNode,tmp.ann)

    #### Get CladeSizeDetail
    message("**** 6. Get CladeSizeDetail file.")
    tmp.CladeSizeDetial <- fun.GetCladeSizeDetail(tmp.pureNode2organ)

    #### Get Np
    message("**** 7. Get Np file.")
    tmp.EffN <- dplyr::left_join(tmp.CladeSizeDetial,fun.GetEffN(tmp.pureNode2organ),by="TipAnn")

    tmp.out <- list()
    tmp.out[["Tree"]] <- tmp.tree
    tmp.out[["Ann"]] <- tmp.ann
    tmp.out[["PureNode"]] <- tmp.pureNode
    tmp.out[["PureNode2Organ"]] <- tmp.pureNode2organ
    tmp.out[["EffN"]] <- tmp.EffN

    Result.EffN <- tmp.out

    if(!is.null(tmp.fileout)){ save(Result.EffN,file=tmp.fileout) }

    if(ReturnNp){ return(tmp.out) }

    message("**** Finish.")
}
