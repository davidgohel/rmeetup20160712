library(ggiraph)

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
head(crimes)
crimes$onclick <- sprintf("window.open(\"%s%s\")",
                          "http://en.wikipedia.org/wiki/", as.character(crimes$state) )

gg_crime <- ggplot(crimes, aes(x = Murder, y = Assault, color = UrbanPop )) +
  geom_point_interactive(
    aes( data_id = state, tooltip = state, onclick = onclick ), size = 3 ) +
  scale_colour_gradient(low = "#999999", high = "#FF3333") +
  theme_minimal()

ggiraph(code = print(gg_crime),
        hover_css = "fill-opacity:.3;cursor:pointer;")

