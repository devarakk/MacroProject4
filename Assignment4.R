#install.packages("ipumsr")
# NOTE: To load data, you must download both the extract's data and the DDI
# and also set the working directory to the folder with these files (or change the path below).

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages('ipumsr')")

ddi <- read_ipums_ddi("cps_00006.xml")
data <- read_ipums_micro(ddi)

# Make Employment Status Categories
data <- data %>%
  mutate(
    category = case_when(
      EMPSTAT %in% 01:12 ~ "Employed",
      EMPSTAT %in% 20:22 ~ "Unemployed",
      EMPSTAT %in% 30:36 ~ "NILF",
      TRUE ~ "NIU"  # optional: for unrecognized values
    )
  )

# Make Panel Data
library(data.table)

# Convert to data.table
panel_dt <- as.data.table(data)
setkey(panel_dt, CPSIDP, YEAR, MONTH)

# Lag EMPSTAT to track previous status
panel_dt[, EMPSTAT_lag := shift(EMPSTAT), by = CPSIDP]

panel_dt <- panel_dt[AGE >= 16]


panel_dt[, EMPSTAT_cat := fifelse(EMPSTAT %in% 01:12, "Employed",
                                  fifelse(EMPSTAT %in% 20:22, "Unemployed",
                                          fifelse(EMPSTAT %in% 30:36, "NILF", NA_character_)))]

panel_dt[, EMPSTAT_lag_cat := fifelse(EMPSTAT_lag %in% 01:12, "Employed",
                                      fifelse(EMPSTAT_lag %in% 20:22, "Unemployed",
                                              fifelse(EMPSTAT_lag %in% 30:36, "NILF", NA_character_)))]

panel_dt[, transition := paste0(EMPSTAT_lag_cat, "_to_", EMPSTAT_cat)]

# Filter to valid transitions
valid_transitions <- panel_dt[!is.na(transition) & !is.na(EMPSTAT_lag_cat)]

# Count transitions and origin group sizes
transition_rates <- valid_transitions[,
                                      .(count = .N),
                                      by = .(EMPSTAT_lag_cat, transition)
]

# Calculate rates: count / total in starting category
transition_rates[, total_origin := sum(count), by = EMPSTAT_lag_cat]
transition_rates[, rate := count / total_origin]

transition_rates <- valid_transitions[,
                                      .(count = .N),
                                      by = .(YEAR, MONTH, EMPSTAT_lag_cat, transition)
]

transition_rates[, total_origin := sum(count), by = .(YEAR, MONTH, EMPSTAT_lag_cat)]
transition_rates[, rate := count / total_origin]


# Create transition rate plots
library(ggplot2)
library(lubridate)

# Create one plot per transition
unique_transitions <- unique(transition_rates$transition)

plots <- lapply(unique_transitions, function(tr) {
  ggplot(transition_rates[transition == tr], aes(x = date, y = rate)) +
    geom_line(color = "darkgreen", size = 1) +
    labs(
      title = paste("Transition Rate:", tr),
      x = "Date",
      y = "Rate"
    ) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    theme_minimal()
})

# View the U2N one
print(plots[[3]])
#View the E2U one
print(plots[[6]])
#View the N2U one
print(plots[[8]])
#View the U2E one
print(plots[[9]])

# Calculate Non-Employment and Unemployment Rates

monthly_status <- panel_dt %>%
  group_by(YEAR, MONTH, category) %>%
  summarise(count = n(), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = category, values_from = count, values_fill = 0)

monthly_status <- monthly_status %>%
  mutate(
    labor_force = Employed + Unemployed,
    total_population = Employed + Unemployed + NILF,
    unemployment_rate = Unemployed / labor_force,
    nonemployment_rate = (Unemployed + NILF) / total_population,
    date = lubridate::make_date(YEAR, MONTH, 1)
  )

# Graph Unemployment and Nonemployment Rates

ggplot(monthly_status, aes(x = date, y = unemployment_rate)) +
  geom_line(color = "firebrick", size = 1) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Monthly Unemployment Rate",
    x = "Date",
    y = "Unemployment Rate"
  ) +
  theme_minimal()

ggplot(monthly_status, aes(x = date, y = nonemployment_rate)) +
  geom_line(color = "steelblue", size = 1) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Monthly Non-Employment Rate",
    x = "Date",
    y = "Non-Employment Rate"
  ) +
  theme_minimal()
