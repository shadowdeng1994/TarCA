#' Adjust polytomy with maximum coalescent rate
#'
#' @param RRResult The list of result obtained from Np_Estimator.
#'
#' @return A dataframe containing lower and upper boundary.
#' @export
#'
#' @examples
#' library(TarCA)
#' load(system.file("Exemplar","Exemplar_TCA.RData",package = "TarCA"))
#' fun.AdjustPolytomy(ExemplarData_1)
#'
fun.AdjustPolytomy <- function(RRResult){

  RRResult %>%
  subfun.EstMinimumEffN %>%
  rbind(RRResult$EffN %>% mutate(TipAnn=paste0(TipAnn,"|Up"))) %>%
  separate(TipAnn,c("TipAnn","Boundary"),"\\|") %>%
  gather(CCC,VVV,-TipAnn,-Total,-Boundary) %>%
  unite(CCC,Boundary,col="CCC",sep="_") %>%
  spread(CCC,VVV) %>%
  mutate(EffN_Low=EffN_Low %>% as.numeric,EffN_Up=EffN_Up %>% as.numeric)
}

subfun.EstMinimumEffN <- function(RRResult){
  tmp.tree <- RRResult$Tree
  tmp.purenode2organ <- RRResult$PureNode2Organ

  tmp1 <- tmp.purenode2organ

  tmp2 <-
  tmp1 %>%
  slice(grep("Node_",Parent,invert = T)) %>%
  group_by(Parent) %>% mutate(ParentID=match(Parent,tmp.tree$tip.label),BigMom=phytools::getParent(tmp.tree,ParentID)) %>%
  mutate(BigMomID=BigMom-subfun.NTip(tmp.tree),BigMomLabel=tmp.tree$node.label[BigMomID]) %>%
  group_by(Parent=BigMomLabel,TipAnn) %>% summarise(Count=n())

  tmp3 <-
  tmp1 %>%
  slice(grep("Node_",Parent)) %>%
  rbind(tmp2) %>%
  mutate(TipAnn=paste0(TipAnn,"|Low"))

  left_join(
    tmp3 %>% fun.GetEffN,
    tmp3 %>% fun.GetCladeSizeDetail
  )
}


