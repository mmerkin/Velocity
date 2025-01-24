library(tidyverse)
library(scales)
library(DescTools)


dir <- "~/Downloads/HC_2017_NEs"

files <- list.files(dir)


df <- data.frame()
for (i in 1:755) {
Nes <- numeric(length=length(files))
for (j in 1:length(files)) {
  file <- read.table(files[j], header=F)
  Nes[j] <- file[i,2]
}
df <- rbind(df, Gmean(Nes, conf.level = 0.95))
}

colnames(df) <- c("mean", "lower", "upper")
df$Generation  <- 1:nrow(df)

df2 <- filter(df, Generation <= 100)

ggplot(df2, aes(x=Generation, y=mean)) +
  geom_ribbon(aes(ymin=lower, ymax=upper), alpha = 0.2, fill="grey50") +
  geom_line(aes(y=lower), colour="blue", linetype="dashed") +
  geom_line(aes(y=upper), colour="blue", linetype="dashed") +
  geom_line() +
  theme_classic() +
  labs(title = expression(italic("Hesperia comma")),
       subtitle= "modern core, n=20",
       caption = "Based on 40 replicates of subsampling 2,000,000 SNPs",
       x="Generation",
       y=expression(italic(N[e]))) +
  scale_x_continuous(breaks = pretty_breaks(n=20),
                     sec.axis=sec_axis(~ 2017 - ., name="Year", breaks= seq(2017, 1917, -5)))
  
