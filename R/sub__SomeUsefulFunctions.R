subfun.GetTipAnnotation <- function(TTTree,NNNode,AAAnn,CCCol){
  tmp <- subfun.GetTips(TTTree,NNNode) %>% tbl_df
  names(tmp) <- CCCol
  left_join(tmp,AAAnn,by=CCCol)
}

subfun.GetTips <- function(TTTree,NNNode){
  castor::get_subtree_at_node(TTTree,NNNode)$subtree$tip.label
}

subfun.NTip <- function(TTTree){
  length(TTTree$tip.label)
}
