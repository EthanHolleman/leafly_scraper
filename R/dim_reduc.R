library(umap)
library(ggplot2)
library(glmnet)
library(randomForest)

read_strain_data <- function(strain.path){
  as.data.frame(read.csv(strain.path))
}
s = '/home/ethan/Documents/github/leaflyScrape/strains.csv'

subset_for_terp <- function(strain.df, terp_only=FALSE){
  terps <- subset(strain.df, 
         !is.na(caryophyllene) & !is.na(humulene) & !is.na(limonene) & 
         !is.na(linalool) & !is.na(ocimene) & !is.na(pinene) & !is.na(terpinolene)
  )
  if (terp_only==TRUE){
    terps <- subset(strain.df, 
          !is.na(caryophyllene) & !is.na(humulene) & !is.na(limonene) & 
          !is.na(linalool) & !is.na(ocimene) & !is.na(pinene) & !is.na(terpinolene),
          c('caryophyllene', 'humulene', 'limonene', 'linalool', 'myrcene', 
            'ocimene', 'pinene', 'terpinolene')
    )
  }
  terps
}

subset_for_attributes <- function(strain.df, attr_only=FALSE){
  attrs <- subset(strain.df, 
              !is.na(relaxed) & !is.na(euphoric) & !is.na(happy) & 
              !is.na(uplifted) & !is.na(sleepy) & !is.na(creative) & 
              !is.na(hungry) & !is.na(tingly) & !is.na(talkative) & 
              !is.na(giggly) & !is.na(aroused) & !is.na(energetic)
                  )
  if (attr_only){
    attrs_strings <- c("relaxed","euphoric","happy","uplifted","sleepy","creative",
               "hungry","tingly","focused","talkative","giggly","aroused",
               "energetic")
    attrs <- attrs[, attrs_strings]
  }
  attrs
}

umap_terps <- function(strain.df){
  strain.df.terps <- subset_for_terp(strain.df)
  strains.df.terps.only <- subset_for_terp(strain.df, TRUE)
  terps.umap <- umap(strains.df.terps.only)
  strain.df.terps$umap_1 <- terps.umap$layout[, 1]
  strain.df.terps$umap_2 <- terps.umap$layout[, 2]
  strain.df.terps
}

umap_attrs <- function(strain.df){
  
  strain.df.attr <- subset_for_attributes(strain.df)
  attr.only <- subset_for_attributes(strain.df, T)
  attr.umap <- umap(attr.only)
  strain.df.attr$umap_1 <- attr.umap$layout[, 1]
  strain.df.attr$umap_2 <- attr.umap$layout[, 2]
  strain.df.attru2
}

plot_umap <- function(df.umap, fill_by){
  df.umap <- subset(df.umap, umap_2 < 15)
  plot <- ggplot(df.umap, aes(x=umap_1, y=umap_2, color=averageRating)) +
           geom_point()
  
  fig <- plot_ly(df.umap)
  fig <- fig %>%
    add_trace(
      type='scatter',
      mode='markers',
      marker = list(color=~averageRating, alpha=0.8),
      x = ~umap_1,
      y = ~umap_2,
      text = ~slug,
      color = ~averageRating,
      showlegend = FALSE,
      hovertemplate = paste(
        '<b>Strain: %{text}</b><br>',
        "Average Rating: %{marker.color:.2f}<br>"
      )
    )
  fig
}

attribute_boxplot <- function(strain.df){
  ggplot(strain.df, aes())
  
  
}


phenotype_rf_model <- function(strain.df, data='terpines', ntree=500){
  
  strain.df$phenotype <- factor(strain.df$phenotype)
  if (data == 'terpines'){
    strain.df.all <- subset_for_terp(strain.df)
    strain.df <- subset_for_terp(strain.df, T)
  }
  else{
    strain.df.all <- subset_for_attributes(strain.df)
    strain.df <- subset_for_attributes(strain.df, T)
  }
  
  strain.df$phenotype <- strain.df.all$phenotype
  strain.df <- subset(strain.df, phenotype == 'Hybrid' | phenotype == 'Indica' | phenotype == 'Sativa')
  strain.df$phenotype <- droplevels(strain.df$phenotype)
  
  
  data_size <- floor(nrow(strain.df) / 2)
  indices <- sample(1:nrow(strain.df), size=data_size)
  training <- strain.df[indices, ]
  validation <- strain.df[-indices, ]
  classifier <- randomForest(phenotype ~ ., data=training, ntree=ntree,
                             importance=TRUE)
  predicted <- predict(classifier, validation)
  list(classifier, predicted, validation)
}








