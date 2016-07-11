# Avec ReporteRs -----

library(ReporteRs)
library(ggplot2)

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
head(crimes)
gg_crime <- ggplot(crimes, aes(x = Murder, y = Assault, color = UrbanPop )) +
  geom_point(
    aes( data_id = state ), size = 3 ) +
  scale_colour_gradient(low = "#999999", high = "#FF3333") +
  theme_minimal()

pptx %>%
  addSlide("Title and Content") %>%
  addTitle("Mon titre") %>%
  addPlot(fun = print, x = gg_crime ) %>%
  writeDoc("example.pptx")

# Avec RVG -----
library(rvg)
write_docx(file = "example_rvg.docx", code = print(gg_crime))

