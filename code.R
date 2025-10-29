# Load Libraries ----------------------------------------------------------
library(tidyverse)
library(ggcorrplot)
library(car)
library(rjags)
library(leaps)
library(knitr)

# Load Data ---------------------------------------------------------------
nc_obama_2012 <- readxl::read_xls("Obama2012.xls")

# Table 2 Summary ---------------------------------------------------------
t(
  sapply(
    nc_obama_2012[, -1], function(x) {
      c(
        Mean = round(mean(x), 2),
        Median = round(median(x), 2),
        SD = round(sd(x), 2),
        Min = round(min(x), 2),
        Max = round(max(x), 2)
      )
    }
  )
) %>% kable(caption = "Summary Statistics")


# Corr Plot ---------------------------------------------------------------
ggcorrplot(cor(nc_obama_2012[, -1]), type = "lower")


# Model Selection ---------------------------------------------------------
all_subsets <- regsubsets(
  PCTOBAMA ~ .,
  data = nc_obama_2012[, -1],
  nvmax = NULL
)
subsets_summary <- summary(all_subsets)

with(subsets_summary, {
  par(mfrow = c(2, 2))
  plot(
    1:11,
    adjr2,
    type = "l",
    xlab = "Parameter Count",
    ylab = "Adjusted R2"
  )
  plot(
    1:11,
    cp,
    type = "l",
    xlab = "Parameter Count",
    ylab = "Mallows' CP"
  )
  plot(
    1:11,
    bic,
    type = "l",
    xlab = "Parameter Count",
    ylab = "BIC"
  )
  plot(
    1:11,
    rss,
    type = "l",
    xlab = "Parameter Count",
    ylab = "RSS"
  )
})


# Multicollineraity Check  ------------------------------------------------
lm(
  PCTOBAMA ~ PctWhite + DiversityIndex + post_sec_edu,
  data = nc_obama_2012
) %>%
  vif() %>%
  kable(col.names = "VIF", caption = "Multicolinearity Check")


# Final Model -------------------------------------------------------------
mlr_freq <- lm(
  PCTOBAMA ~ PctWhite + post_sec_edu, 
  data = nc_obama_2012[, -1]
)
mlr_freq_summary <- summary(mlr_freq)
kable(mlr_freq_summary[["coefficients"]])


# Model Assumptions -------------------------------------------------------
plot(
  mlr_freq$fitted.values, 
  mlr_freq$residuals, 
  xlab = "Fitted Values",
  ylab = "Residuals",
  main = "Versus Fits"
)
abline(0, 0, lty = 2)

par(mfrow = c(1, 2))
qqnorm(mlr_freq$residuals)
qqline(mlr_freq$residuals)
hist(
  mlr_freq$residuals, 
  xlab = "Residuals", 
  main = "Histogram of Residuals"
)
shapiro.test(mlr_freq$residuals)

plot(
  mlr_freq$residuals, 
  xlab="Residual orders", 
  ylab="Residual value",
  main = "Versus Order"
)
abline(0, 0, lty = 2)
durbinWatsonTest(mlr_freq)


# Bayesian Model ----------------------------------------------------------
mlr_bayes <- "model{

  # Likelihood function - data distribution
  for(i in 1:n){
    PCTOBAMA[i] ~ dnorm(beta0 + beta1 * PctWhite[i] + beta2 * post_sec_edu[i], tau2)
  }

  # Prior for beta
  beta0 ~ dnorm(0.9, 1 / (0.05))
  beta1 ~ dnorm(0, 1 / 100)
  beta2 ~ dnorm(0, 1 / 100)

  # Prior for the inverse variance
  tau2 ~ dgamma(0.1, 0.1)
  sigma2 <- 1/tau2
}"

n <- nrow(nc_obama_2012)

reg_model <- jags.model(
  textConnection(mlr_bayes),
  n.chains = 3,
  data = list(
    PCTOBAMA = nc_obama_2012$PCTOBAMA, # Response
    PctWhite = nc_obama_2012$PctWhite, # B1
    post_sec_edu = nc_obama_2012$post_sec_edu, #B2
    n = n
  )
)

update(reg_model, 10000, progress.bar = "none")
post_samples <- coda.samples(
  reg_model,
  variable.names = c("beta0", "beta1", "beta2", "sigma2"),
  n.iter = 20000,
  progress.bar = "none"
)
mlr_bayes_summary <- summary(post_samples)
kable(mlr_bayes_summary$statistics, caption = "Coefficient Summary")
kable(mlr_bayes_summary$quantiles, caption = "Coefficient Quantiles")



# Trace Plots -------------------------------------------------------------
plot(post_samples)


# Gelman Plot -------------------------------------------------------------
gelman.plot(post_samples)


# Effective Sample Size ---------------------------------------------------
kable(
  effectiveSize(post_samples), 
  col.names = "Effective Sample Size", 
  round = 2
  caption = "Effective Sample Size"
)
