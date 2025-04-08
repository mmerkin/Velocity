library(tidyverse)

plot_MEs <- function(tsv, invert=F) {

  
# Read in data
data <- read_tsv(paste0(wd, "/", tsv))
species <- str_remove(tsv, "_merian_elements.tsv")

if (invert==F){

# Calculate fraction of each ME comprising each chromosome

df_summary <- data %>%
  group_by(chr, ME) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  group_by(chr) %>%
  mutate(fraction = count / sum(count)) %>%
  ungroup()

# Identify chromosomes that are >50% of a single ME and sort them starting from M1

chr_order <- df_summary %>%
  filter(fraction > 0.5) %>%
  arrange(factor(ME, levels = c(paste0("M", 1:31), "MZ"))) %>%
  pull(chr) # Return just the chr column rather than the entire df

# Add in any missing chromosomes that were <50% of any ME
chr_order <- unique(c(chr_order, df_summary$chr))
# Reorder the chromosomes and MEs to start with the highest fraction of M1 in the top left
df_summary$chr <- factor(df_summary$chr, levels = chr_order)
df_summary$ME <- factor(df_summary$ME, levels = c("MZ", paste0("M", 31:1)))

# Create a heatmap
ggplot(df_summary, aes(x = chr, y = ME, fill = fraction)) +
  geom_tile(height = 0.8, width = 0.8) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(y = "Merian element", x = "Chromosome", fill = "Fraction",
       title=species) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  
} else { 
  
  # Calculate fraction of each chromosome comprising each ME
  
  df_summary <- data %>%
    group_by(ME, chr) %>%
    summarise(count = n()) %>%
    ungroup() %>%
    group_by(ME) %>%
    mutate(fraction = count / sum(count)) %>%
    ungroup()
  
  ME_order <- df_summary %>%
    filter(fraction > 0.5) %>%
    arrange(desc(chr)) %>%
    pull(ME)
  
  ME_order <- unique(c(ME_order, df_summary$ME))
  df_summary$ME <- factor(df_summary$ME, levels = ME_order)
  
  # Create a heatmap
  ggplot(df_summary, aes(x = ME, y = chr, fill = fraction)) +
    geom_tile(height = 0.8, width = 0.8) +
    scale_fill_gradient(low = "lightblue", high = "darkblue") +
    labs(y = "Chromosome", x = "Merian element", fill = "Fraction",
         title=species) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
}
}
wd <- "~/Documents/Velocity/Phylogeny/MEs"
files <- list.files(wd)


# Example to plot the third file in the directory 

plot_MEs(files[3])
