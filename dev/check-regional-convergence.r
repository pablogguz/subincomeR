
devtools::load_all()
library(dplyr)
library(ggplot2)
library(extrafont)
library(ggtext)
library(fixest)
library(countrycode)

# Theme 
theme_convergence <- function() {
  theme_minimal() +
    theme(
      text = element_text(family = "Open Sans", size = 16),
      plot.title = element_text(size = 18, margin = margin(b = 20)),
      plot.subtitle = element_text(size = 14, color = "grey40"),
      plot.caption = element_textbox_simple(
        size = 12, 
        color = "grey40", 
        margin = margin(t = 20),
        hjust = 0
      ),
      legend.position = "top",
      legend.justification = "left",
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(size = 14)
    )
}

# Load DOSE data
data <- getDOSE(years = c(2000, 2019))  # Using 2010-2019 period

# Calculate growth rates and initial income
convergence_data <- data %>%
    # filter missing values 
    filter(!is.na(grp_pc_usd_2015)) %>%
    # keep all regions with data for both years
    group_by(GID_1) %>%
    filter(n() == 2) %>%
    arrange(year) %>%
    summarize(
        initial_pop = first(pop),
        initial_income = first(grp_pc_usd_2015),
        final_income = last(grp_pc_usd_2015),
        growth_rate = (log(final_income) - log(initial_income)) / (max(year) - min(year)),
        country = first(GID_0)
    ) %>%
    ungroup() %>%
    # get continent
    mutate(
      continent = countrycode(country, origin = "iso3c", destination = "continent")
    ) 

# Run convergence regression
model <- feols(
  growth_rate ~ log(initial_income), 
  data = convergence_data,
  vcov = "hetero"
)

# Create formatted coefficients for the plot subtitle
model_stats <- summary(model)
beta <- coef(model)["log(initial_income)"]
pval <- model_stats$coeftable["log(initial_income)", "Pr(>|t|)"]

# Plot
continent_colors <- c(
  "Africa" = "#E31C1C",       # Red
  "Asia" = "#0066CC",         # Blue
  "Europe" = "#4DAF4A",       # Green
  "Americas" = "#984EA3",     # Purple
  "Oceania" = "#FF7F00"       # Orange
)

ggplot(convergence_data, 
       aes(x = log(initial_income), 
           y = growth_rate * 100)) + 
  geom_point(
    aes(size = initial_pop,
        color = continent),
    alpha = 0.4
  ) +
  geom_smooth(
    method = "lm",
    color = "#0072B2",
    linewidth = 1.5,
    se = TRUE,
    alpha = 0.5
  ) +
  annotate(
    "text",
    x = 10.5,
    y = 7,
    label = sprintf("β = %.3f\n(p = %.3f)", beta, pval),
    hjust = 0,
    size = 5,
    family = "Open Sans"
  ) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%")
  ) +
  scale_size_continuous(
    range = c(1, 8),
    guide = "none"
  ) +
  scale_color_manual(
    values = continent_colors,
    name = NULL
  ) +
  labs(
    title = "Regional Income Convergence, 2000-2019",
    x = "Log Initial Income (2000)",
    y = "Average Annual Growth Rate",
    caption = "**Data** DOSE dataset | **Plot** @pablogguz_"
  ) +
  theme_convergence() +
  theme(
    legend.position = "top",
    legend.direction = "horizontal",
    legend.justification = "left",
    legend.key.size = unit(1, "lines"),   
    legend.margin = margin(t = 0, b = 0)
  ) +
  guides(
    color = guide_legend(override.aes = list(size = 4)) 
  )

# Now with FEs:
model_conditional <- feols(
  growth_rate ~ log(initial_income) | country, 
  data = convergence_data,
  vcov = "hetero"
)

# Compare models
etable(model, model_conditional,
       title = "Regional Convergence Results",
       headers = c("Absolute", "Conditional"),
       se.below = TRUE,
       keep = "log",
       notes = "Heteroskedasticity-robust standard errors in parentheses.")
