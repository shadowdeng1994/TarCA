#' Check input file
#'
#' @param TTTree A tree file of class "phylo" with node labels (using node ID by default).
#' @param AAAnn A dataframe with TipLabel and TipAnn (tip labels on the tree file and corresponding cell annotations).
#' @param FFFileout A path to output (e.g. tmp.RData).
#'
#' @return A processed tree.
#'
fun.CheckInput <- function(TTTree,AAAnn,FFFileout){
    if(length(grep("TipLabel",colnames(AAAnn)))==0){
        message("**** Column TipLabel is missing in Ann file. Quit...")
        return()
    }
    if(length(grep("TipAnn",colnames(AAAnn)))==0){
        message("**** Column TipAnn is missing in Ann file. Quit...")
        return()
    }
    tmp1 <- TTTree$tip.label %>% unique
    tmp2 <- AAAnn$TipLabel %>% unique
    if(length(tmp1)!=length(TTTree$tip.label)){
        message("**** Tips of the phylogeny are non-unique. Quit...")
        return()
    }
    if(length(intersect(tmp1,tmp2))!=length(tmp1)){
        message("**** Tips of the phylogeny do not match the Ann file. Quit...")
        return()
    }
    if(length(grep("/",FFFileout))>0){
        if(!file.exists(paste(rev(rev(strsplit(FFFileout,"/")[[1]])[-1]),collapse="/"))){
            message("**** Can not reach ",FFFileout,". Quit...")
            return()
        }
    }

    tmp.out <- TTTree
    if(is.null(tmp.out$node.label)){
        message("**** Node labels are missing, assigning with node IDs.")
        tmp.out$node.label <- paste0("Node_",1:tmp.out$Nnode)
    }

    return(tmp.out)
}


