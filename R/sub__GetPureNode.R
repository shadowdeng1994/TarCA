#### Get pureNode file
fun.GetPureNode <- function(TTTreeData,AAAnn,NNNode2Tip){
    subfun.GetImpureNode(TTTreeData,AAAnn) %>%
    subfun.FilterImpureNode(NNNode2Tip) %>%
    rename(label=Parent) %>% subfun.AddTreeHeight(TTTreeData) %>%
    rename(Parent=label) %>% arrange(Height) %>% .$Parent %>%
    subfun.GetPureNode(NNNode2Tip,AAAnn)
}

subfun.GetImpureNode <- function(TTTreeData,AAAnn){
    TTTreeData %>%
    filter(isTip) %>%
    select(parent,TipLabel=label) %>%
    left_join(AAAnn,by="TipLabel") %>%
    group_by(parent) %>% summarise(Count=TipAnn %>% unique %>% length) %>%
    filter(Count>1) %>%
    left_join(TTTreeData %>% filter(!isTip) %>% group_by(parent=node,label) %>% summarise,by="parent") %>%
    mutate(Toxin=1) %>%
    select(Label=label,Toxin)
}

subfun.FilterImpureNode <- function(TTToxin,NNNode2Tip){
    TTToxin %>%
    right_join(NNNode2Tip,by="Label") %>%
    group_by(Parent) %>% filter(all(is.na(Toxin))) %>% summarise %>%
    group_by
}

subfun.AddTreeHeight <- function(DDData,TTTreeData){
    DDData %>% left_join(TTTreeData %>% select(label,Height=x) %>% unique,by="label")
}

subfun.GetNodeID2NodeLabel <- function(TTTreeData){
    TTTreeData %>%
    filter(!isTip) %>%
    mutate(node=node-sum(TTTreeData$isTip)) %>%
    select(node,NodeLabel=label) %>%
    arrange(node)
}

subfun.GetPureNode <- function(PPParents,NNNode2Tip,AAAnn){
    tmp.set <- PPParents
    tmp.res <- list()
    tmp.finish <- PPParents[1]

    while(length(tmp.set)>0){
        ppp <- tmp.set[1]

        tmp1 <-
        NNNode2Tip %>% filter(Parent==ppp)
        tmp2 <-
        tmp1 %>%
        filter(Type=="Tip") %>%
        rename(TipLabel=Label) %>%
        left_join(AAAnn,by="TipLabel") %>%
        select(Parent,TipAnn,TipLabel)
        tmp3 <-
        tmp2 %>% .$TipAnn %>% unique %>% length

        tmp.finish <- c(tmp.finish,ppp)
        if(tmp3==1){
            tmp.res[[ppp]] <- tmp2
            tmp.finish <- c(tmp.finish,tmp1 %>% filter(Type=="Node") %>% .$Label) %>% unique
        }
        tmp.set <- setdiff(tmp.set,tmp.finish)
    }
    tmp.out <- tmp.res %>% bind_rows
    return(tmp.out)
}
