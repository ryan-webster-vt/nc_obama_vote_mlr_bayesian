# Predicting Obama's 2012 Vote Share in North Carolina

A comprehensive statistical analysis using Multiple Linear Regression to predict and identify key demographic factors influencing President Obama's vote share across North Carolina counties in the 2012 presidential election.

## Overview

This project employs both frequentist (Ordinary Least Squares) and Bayesian approaches to develop predictive models using demographic, economic, and educational data from all 100 counties in North Carolina.

## Dataset

The analysis uses county-level data with the following variables:

**Response Variable:**
- `PCTOBAMA` - Obama's vote share in each county

**Predictor Variables:**
- `Pop2010` - Population as of 2010
- `PopPerSqMile` - Population density
- `PctWhite` - Percent of population that is White
- `PctBlack` - Percent of population that is Black
- `PctAmericanIndian` - Percent of population that is American Indian
- `PctAsian` - Percent of population that is Asian
- `PctHisp` - Percent of population that is Hispanic
- `DiversityIndex` - County diversity measure
- `pct_Uninsured` - Percent of population uninsured
- `post_sec_edu` - Percent with post-secondary education
- `pct_unemployed` - Percent unemployed

**Dataset Characteristics:**
- 100 observations (one per county)
- 12 covariates
- Mean Obama vote share: 44%
- Range: 24% to 76%

## Methodology

### Model Selection

1. **Correlation Analysis**: Initial exploration using correlation heatmaps revealed strong relationships between vote share and racial demographics
2. **Best Subset Selection**: Used the `leaps` library to evaluate models based on Adjusted R², Mallows' CP, BIC, and RSS
3. **Multicollinearity Check**: VIF values were calculated to identify problematic correlations between predictors
4. **Final Model**: Selected a two-variable model to avoid multicollinearity issues

### Final Model Variables

- `PctWhite` - Percent of White population
- `post_sec_edu` - Percent with post-secondary education

**Model Equation:**
```
PCTOBAMA = 0.712 - 0.606(PctWhite) + 0.003(post_sec_edu) + ε
```

## Key Findings

### Frequentist Analysis (OLS)
- **PctWhite**: Coefficient = -0.606 (p < 0.001)
  - Each 1% increase in White population decreases Obama's vote share by 0.606%
- **post_sec_edu**: Coefficient = 0.003 (p < 0.001)
  - Each 1% increase in post-secondary education increases Obama's vote share by 0.003%

### Bayesian Analysis
- Used Gibbs sampling with RJAGS
- Uninformative priors for slope coefficients
- Informative prior for intercept based on historical voting patterns
- Results closely matched OLS estimates:
  - Intercept: 0.719
  - PctWhite: -0.609
  - post_sec_edu: 0.003

### Model Diagnostics

**Assumptions Tested:**
- ✅ Constant Variance: Confirmed via residual plots
- ⚠️ Normality: Shapiro-Wilk test showed evidence of non-normal residuals (p = 0.0002)
- ✅ Independence: Durbin-Watson test confirmed independence (p = 0.106)

**Convergence Diagnostics (Bayesian):**
- Trace plots showed good mixing across three chains
- Gelman-Rubin statistics indicated successful convergence
- Effective sample sizes ranged from 778 to 45,911

## Requirements

```r
# R packages required
library(leaps)        # Best subset selection
library(car)          # VIF calculation
library(lmtest)       # Durbin-Watson test
library(rjags)        # Bayesian MCMC
library(coda)         # MCMC diagnostics
```

## Interpretation

The analysis reveals that racial demographics (specifically the percentage of White population) were the strongest predictor of Obama's vote share in North Carolina counties during the 2012 election. Educational attainment also played a statistically significant but smaller role. These findings align with well-documented voting patterns from the 2012 election cycle.

## Limitations

1. Non-normal residuals suggest potential model misspecification or outliers
2. The model explains voting patterns but does not establish causality
3. County-level aggregation may mask individual-level voting behavior
4. Limited to 2012 election data; patterns may differ in other election years

## Author

Ryan Webster
STAT 4444 Final Project

## License

This project is for educational purposes as part of a statistical analysis course.

---

*Note: This analysis is a historical examination of 2012 election data and is intended for statistical learning purposes only.*
