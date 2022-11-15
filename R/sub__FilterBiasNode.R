fun.FilterBiasNode <- function(BBBiasNode,TTTree){
  ## this function is used for filtering the bias node on different hierarchy.
  ##      0.5-------(x)
  ##       |
  ##      0.8-------(v)
  ##       |
  ##      0.8-------(x)

  ## extract the relationship between ancestors and offsprings
  tmp.isP2D <- subfun.GetP2D(BBBiasNode,TTTree)

  if(nrow(tmp.isP2D)>0){
    ## there're P-D among bias nodes.

    ## extract the bias level of ancestors and offsprings.
    tmp.PDBias <- subfun.GetPDBias(tmp.isP2D,BBBiasNode,TTTree)

    ## filter the internal nodes that have lower bias level compared with their offsprings.
    tmp.SuckParent <- subfun.FilterBadParent(tmp.PDBias,BBBiasNode)

    ## filter the internal nodes that do not have higher bias level than their parents.
    tmp.SuckDaughter <- subfun.FilterBadDaughter(tmp.SuckParent,TTTree)

    tmp.out <- subfun.FilterBadNode(tmp.SuckDaughter,BBBiasNode)
  }else{
    ## there are no P-D among bias nodes.
    tmp.out <- BBBiasNode %>% mutate(Filter=TRUE) %>% select(node,Filter,NodeID,Bias,pval,padj)
  }

  return(tmp.out)
}




# ==============================
subfun.GetP2D <- function(BBBiasNode,TTTree){
  BBBiasNode$node %>%
  list(.,.) %>%
  fun.GetCombinationFromList %>%
  filter(V1<V2) %>%
  group_by(V1,V2) %>% mutate(MRCA=castor::get_pairwise_mrcas(TTTree,V1,V2)) %>%
  filter(V1==MRCA)
}


subfun.GetPDBias <- function(IIIsP2D,BBBiasNode,TTTree){
  IIIsP2D %>%
  group_by %>% arrange(V2) %>%
  group_by(V1,V2) %>% mutate(H1=phytools::nodeheight(TTTree,V1)) %>%
  group_by(V2) %>% filter(min_rank(-H1)==1) %>%
  left_join(BBBiasNode %>% select(V1=node,B1=Bias),by="V1") %>%
  left_join(BBBiasNode %>% select(V2=node,B2=Bias),by="V2")
}

subfun.FilterBadParent <- function(PPPDBias,BBBiasNode){
  BBBiasNode %>%
  left_join(PPPDBias %>% group_by(node=V1) %>% summarise(isParent=1),by="node") %>%
  left_join(PPPDBias %>% group_by(node=V2) %>% summarise(isDaughter=1),by="node") %>%
  left_join(PPPDBias %>% filter(B2>B1) %>% group_by(node=V1) %>% summarise(SuckParent=1),by="node") %>%
  filter(is.na(SuckParent))
}


subfun.FilterBadDaughter <- function(BBBadParent,TTTree){
  list(
    Parent=BBBadParent %>% filter(!is.na(isParent)) %>% .$node,
    Daughter=BBBadParent %>% filter(!is.na(isDaughter)) %>% .$node
  ) %>% fun.GetCombinationFromList %>%
  filter(Parent!=Daughter) %>%
  group_by(Parent,Daughter) %>% mutate(MRCA=castor::get_pairwise_mrcas(TTTree,Parent,Daughter)) %>%
  group_by(node=Daughter) %>% summarise(SuckDaughter=Parent==MRCA) %>%
  right_join(BBBadParent,by="node") %>%
  mutate(SuckDaughter=replace_na(SuckDaughter,FALSE)) %>%
  group_by(node) %>% filter(all(!SuckDaughter))
}

subfun.FilterBadNode <- function(BBBadDaughter,BBBiasNode){
  BBBadDaughter %>%
  group_by(node) %>% summarise(Filter=TRUE) %>%
  right_join(BBBiasNode,by="node") %>%
  mutate(Filter=replace_na(Filter,FALSE))
}


