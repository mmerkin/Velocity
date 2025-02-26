
# Load in libraries

library(tidyverse)
library(cowplot)

# Create a single function that reads in all the files in a directory and plots 
# the average of each substitution type at each read position

generate_plots <- function(wd, height, Add_CpG=FALSE, title=NULL) {
  
  # Read in files
  
  files <- list.files(wd)
  data_list <- map_df(files, function(file) {
    df <- read_tsv(file)
    df$file_name <- gsub(".sort.PMD.txt", "", basename(file)) 
    return(df)
  }) 
  
  # Create required columns in the five prime data, with the option to
  # combine the CpG site data
  
  if (Add_CpG){
    Fiveprime_data <- data_list %>%
      mutate(
        CT_combined = CT5 + CT_CpG_5,
        CA_combined = CA5 + CA_CpG_5,
        CG_combined = CG5 + CG_CpG_5,
        CC_combined = CC5 + CC_CpG_5,
        GA_combined = GA5 + GA_CpG_5,
        GT_combined = GT5 + GT_CpG_5,
        GC_combined = GC5 + GC_CpG_5,
        GG_combined = GG5 + GG_CpG_5,
        AA_combined = AA5 + AA_CpG_5,
        AT_combined = AT5 + AT_CpG_5,
        AC_combined = AC5 + AC_CpG_5,
        AG_combined = AG5 + AG_CpG_5,
        TA_combined = TA5 + TA_CpG_5,
        TT_combined = TT5 + TT_CpG_5,
        TC_combined = TC5 + TC_CpG_5,
        TG_combined = TG5 + TG_CpG_5) 
  } else {
    Fiveprime_data <- data_list %>%
      select(z, file_name,CT5,CA5,CG5,CC5,GA5,GT5,GC5,GG5,AA5,AT5,AC5,AG5,TA5,TT5,TC5,TG5) %>%
      rename_with(~ gsub("([A-Za-z]{1})([A-Za-z]{1})[0-9]+", "\\1\\2_combined", .))
  }
  
  # Extract the desired columns and combine non-deamination substitutions
  
  Fiveprime_data <-Fiveprime_data  %>%
    select(z, file_name, contains("combined")) %>%
    mutate(
      Other_combined = rowMeans(cbind(CA_combined,
                                      CG_combined,
                                      GT_combined,
                                      GC_combined,
                                      AT_combined,
                                      AC_combined,
                                      AG_combined,
                                      TA_combined,
                                      TC_combined,
                                      TG_combined)
      )) %>%
    group_by(z) %>%
    summarise(
      CT = mean(CT_combined, na.rm = TRUE),
      GA = mean(GA_combined, na.rm = TRUE),
      Other = mean(Other_combined, na.rm = TRUE)
    ) %>%
    filter(z != 0)
  
  # Create required columns in the three prime data
  
  if (Add_CpG){
    Threeprime_data <- data_list %>%
      mutate(
      CT_combined = CT3 + CT_CpG_3,
      CA_combined = CA3 + CA_CpG_3,
      CG_combined = CG3 + CG_CpG_3,
      CC_combined = CC3 + CC_CpG_3,
      GA_combined = GA3 + GA_CpG_3,
      GT_combined = GT3 + GT_CpG_3,
      GC_combined = GC3 + GC_CpG_3,
      GG_combined = GG3 + GG_CpG_3,
      AA_combined = AA3 + AA_CpG_3,
      AT_combined = AT3 + AT_CpG_3,
      AC_combined = AC3 + AC_CpG_3,
      AG_combined = AG3 + AG_CpG_3,
      TA_combined = TA3 + TA_CpG_3,
      TT_combined = TT3 + TT_CpG_3,
      TC_combined = TC3 + TC_CpG_3,
      TG_combined = TG3 + TG_CpG_3) 
  } else {
    Threeprime_data <- data_list %>%
      select(z, file_name,CT3,CA3,CG3,CC3,GA3,GT3,GC3,GG3,AA3,AT3,AC3,AG3,TA3,TT3,TC3,TG3) %>%
      rename_with(~ gsub("([A-Za-z]{1})([A-Za-z]{1})[0-9]+", "\\1\\2_combined", .))
  }
  
  # Extract the desired columns and combine non-deamination substitutions
  
  Threeprime_data <-Threeprime_data  %>%
    select(z, file_name, contains("combined")) %>%
    mutate(
      Other_combined = rowMeans(cbind(CA_combined,
                                      CG_combined,
                                      GT_combined,
                                      GC_combined,
                                      AT_combined,
                                      AC_combined,
                                      AG_combined,
                                      TA_combined,
                                      TC_combined,
                                      TG_combined)
      )) %>%
    group_by(z) %>%
    summarise(
      CT = mean(CT_combined, na.rm = TRUE),
      GA = mean(GA_combined, na.rm = TRUE),
      Other = mean(Other_combined, na.rm = TRUE)
    ) %>%
    filter(z != 0, z != 1)
  
  # Create the five prime plot
  
  Fiveprime_data_long <- Fiveprime_data %>%
    pivot_longer(cols = c(CT, GA, Other), names_to = "Substitution_type", values_to = "Substitution_rate")
  Fiveprime_plot <- ggplot(Fiveprime_data_long, aes(x = z, y = Substitution_rate, color = Substitution_type)) +
    geom_line() +
    theme_minimal() +
    scale_color_manual(values = c("CT" = "blue", "Other" = "green", "GA" = "red")) +
    theme_classic() +
    labs(x="Distance from 5` end (bp)", y="Frequency of base substitution") +
    theme(legend.position = "none") +
    scale_x_continuous(breaks = seq(0, 30, by = 5)) +
    scale_y_continuous(breaks = seq(0, height, by = 0.005), limits=c(0, height))
  
  # Create a second copy of the plot to extract the legend
  
  Plot_legend <- ggplot(Fiveprime_data_long, aes(x = z, y = Substitution_rate, color = Substitution_type)) +
    scale_color_manual(values = c("CT" = "blue", "Other" = "green", "GA" = "red")) +
    geom_line() + 
    theme_classic() +
    guides(color = guide_legend(title = "Substitution type"))
  
  # Create the three prime plot
  
  Threeprime_data_long <- Threeprime_data %>%
    pivot_longer(cols = c(CT, GA, Other), names_to = "Substitution_type", values_to = "Substitution_rate")
  Threeprime_plot <- ggplot(Threeprime_data_long, aes(x = z, y = Substitution_rate, color = Substitution_type)) +
    geom_line() +
    theme_minimal() +
    scale_color_manual(values = c("CT" = "blue", "Other" = "green", "GA" = "red")) +
    theme_classic() +
    labs(x="Distance from 3` end (bp)", y="Frequency of base substitution") +
    theme(legend.position = "none") +
    scale_x_reverse(breaks = seq(0, 30, by = 5)) + 
    scale_y_continuous(breaks = seq(0, height, by = 0.005), limits=c(0, height), position = "right") 
  
  # Combine the two deamination profile plots
  
  final_plot <- plot_grid(
    Fiveprime_plot, Threeprime_plot,
    ncol = 2,
    rel_widths = c(1, 1)
  )
  
  # Add the legend
  
  legend_plot <- get_legend(Plot_legend)
  final_plot_with_legend <- plot_grid(final_plot, legend_plot, ncol = 1, rel_heights = c(1, 0.1))
  final_output <- plot_grid(
    final_plot, legend_plot,
    ncol = 2,
    rel_widths = c(0.8, 0.2)
  )
  
  # Add a title if specified
  
  if (!is.null(title)) {
    plot_title <- ggdraw() + 
      draw_label(
        title,
        fontface = 'bold',
        x = 0,
        hjust = -0.1
      ) 
    final_output <- plot_grid(
      plot_title, final_output,
      ncol = 1,
      rel_heights = c(0.1, 1)
    )
  }
  
  return(final_output)
}

wd <- "/path/to/folder/with/platypus/outputs"
setwd(wd)

# Example plots (replace parameters as necessary)

generate_plots(wd=wd, height=0.025, Add_CpG=FALSE, title="Museum ringlet substitutions")
generate_plots(wd=wd, height=0.04, Add_CpG=TRUE, title="Museum ringlet substitutions")
