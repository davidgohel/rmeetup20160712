library(ggplot2)
gg_point <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Width,
                             color = Species) ) + theme_minimal() +
  geom_point(size = 5) +
  scale_colour_manual(values = c("#7570b3","#d95f02", "#1b9e77"))
gg_point

