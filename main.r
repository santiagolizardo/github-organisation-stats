lockBinding("working_dir", globalenv())
setwd(working_dir)

files <- dir(".", pattern = "*.json")

install.packages("rjson")
library("rjson")

repository_lists <- lapply(files, function(f) fromJSON(file = f))
repositories <- do.call(c, repository_lists)

install.packages("rlist")
library("rlist")

repository_df <- data.frame(do.call(rbind, repositories))
dim(repository_df); colnames(repository_df)
typeof(repository_df); print(is.data.frame(repository_df))

install.packages("dplyr")
library("dplyr")

active_repos <- filter(repository_df, archived == "FALSE")
print(is.data.frame(active_repos))
dim(active_repos)

repository_by_archive_df <- repository_df %>%
  group_by(archive_status = repository_df$archived) %>%
  summarise(total = n())


pie_colors <- rainbow(2) # c('blue', 'red') , terrain.colors(2), heat.colors, topo.colors, ...
png("plot-repositories-by-archive-status.png")
pie(repository_by_archive_df$total, labels = repository_by_archive_df$total, main = "Repositories by archive status", col = pie_colors)
legend("topleft", legend = c('Archived', 'Active'), fill = pie_colors)
dev.off()

repository_by_language_df <- active_repos %>%
  group_by(language_group = active_repos$language) %>%
  filter(language_group != "NULL") %>%
  count(sort = TRUE) %>%
  head(20)

head(repository_by_language_df)

png("plot-active-repositories-by-programming-language.png")
barplot(repository_by_language_df$n, names.arg = repository_by_language_df$language_group, xlab = "", ylab = "Repository count", las=2, col = "skyblue",
        main="Programming language count for active repositories",
        ylim=range(pretty(c(0, repository_by_language_df$n)))
)
dev.off()

View(repository_by_language_df)

