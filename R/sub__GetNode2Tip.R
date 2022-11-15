### Get Node2Tip file
fun.GetNode2Tip <- function(TTTree,TTTreeData){
    tmp.set <- subfun.GetNodeID2NodeLabel(TTTreeData)
    tmp.subtrees <- castor::get_subtrees_at_nodes(TTTree,tmp.set$node)$subtrees
    tmp.res <- lapply(1:nrow(tmp.set),function(iii){ subfun.GetOffspringsWithNode(tmp.subtrees[[iii]],tmp.set$NodeLabel[iii]) })  
    tmp.out <- bind_rows(tmp.res)

    return(tmp.out)
}

subfun.GetNodeID2NodeLabel <- function(TTTreeData){
    TTTreeData %>% 
    filter(!isTip) %>% 
    mutate(node=node-sum(TTTreeData$isTip)) %>% 
    select(node,NodeLabel=label) %>% 
    arrange(node)
}

subfun.GetOffspringsWithNode <- function(TTTree,LLLabel){
    rbind(
        data.frame("Type"="Node",Label=TTTree$node.label),
        data.frame("Type"="Tip",Label=TTTree$tip.label)
    ) %>% mutate(Parent=LLLabel) %>% 
    select(Parent,Type,Label)
}
