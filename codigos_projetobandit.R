library(tidyverse)
library(patchwork)
set.seed(2026)

# Função para simular o experimento Parte 1
simular_bandit_normal <- function(T_steps = 500, policy = "uniform") {
  K <- 5
  mu <- rep(0, K)
  sigma <- 1
  
  # Inicialização
  n_a <- rep(0, K)
  sum_a <- rep(0, K)
  
  # Puxar cada braço uma vez para inicializar
  for(a in 1:K) {
    r <- rnorm(1, mu[a], sigma)
    n_a[a] <- 1
    sum_a[a] <- r
  }
  
  for(t in (K+1):T_steps) {
    mu_hat <- sum_a / n_a
    
    if(policy == "uniform") {
      a_t <- sample(1:K, 1)
    } else if(policy == "greedy") {
      a_t <- which.max(mu_hat)
    } else if(policy == "ucb") {
      # c = 2 para UCB
      ucb_score <- mu_hat + 2 * sqrt(log(t) / n_a)
      a_t <- which.max(ucb_score)
    } else if(policy == "ts") {
      # Thompson Sampling: posteriori N(mu_hat, sigma^2/n_a) assumindo priori plana
      theta_sample <- rnorm(K, mean = mu_hat, sd = sigma/sqrt(n_a))
      a_t <- which.max(theta_sample)
    }
    
    r <- rnorm(1, mu[a_t], sigma)
    n_a[a_t] <- n_a[a_t] + 1
    sum_a[a_t] <- sum_a[a_t] + r
  }
  
  mu_hat_final <- sum_a / n_a
  a_star <- which.max(mu_hat_final)
  mu_hat_star <- mu_hat_final[a_star]
  n_star <- n_a[a_star]
  
  # IC 95%
  moe <- 1.96 * sigma / sqrt(n_star)
  ic_lower <- mu_hat_star - moe
  ic_upper <- mu_hat_star + moe
  
  # Cobertura empírica (se 0 está no IC)
  cobertura <- (0 >= ic_lower) & (0 <= ic_upper)
  
  return(data.frame(policy = policy, a_star = a_star, mu_hat_star = mu_hat_star, 
                    n_star = n_star, cobertura = cobertura))
}

n_sims <- 1000
policies <- c("uniform", "greedy", "ucb", "ts")
resultados_p1 <- bind_rows(lapply(policies, function(p) {
  bind_rows(replicate(n_sims, simular_bandit_normal(T_steps = 500, policy = p), simplify = FALSE))
}))

cobertura_resumo <- resultados_p1 %>%
  group_by(policy) %>%
  summarise(cobertura_empirica = mean(cobertura),
            mu_hat_medio = mean(mu_hat_star),
            .groups = 'drop')


knitr::kable(cobertura_resumo, col.names = c("Política", "Cobertura Empírica", "Média de $\\hat{\\mu}_{\\hat{a}}$"), digits = 3)

ggplot(resultados_p1, aes(x = mu_hat_star, fill = policy)) +
  geom_density(alpha = 0.6) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  facet_wrap(~policy) +
  theme_minimal() +
  labs(x = expression(hat(mu)[hat(a)]), y = "Densidade", title = "Distribuição da Média do Braço Selecionado") +
  theme(legend.position = "none")

simular_poisson_bandit <- function(T_steps = 1000, policy = "uniform", epsilon = 0.1) {
  K <- 5
  lambda_true <- c(18, 20, 21, 23, 27)
  
  # Priori Gamma(alpha_0, beta_0)
  alpha_0 <- 2
  beta_0 <- 0.1
  
  alpha_t <- rep(alpha_0, K)
  beta_t <- rep(beta_0, K)
  
  rewards <- numeric(T_steps)
  actions <- numeric(T_steps)
  
  # Inicialização
  for(a in 1:K) {
    r <- rpois(1, lambda_true[a])
    rewards[a] <- r
    actions[a] <- a
    alpha_t[a] <- alpha_t[a] + r
    beta_t[a] <- beta_t[a] + 1
  }
  
  for(t in (K+1):T_steps) {
    # Médias a posteriori
    mu_hat <- alpha_t / beta_t
    
    if(policy == "uniform") {
      a_t <- sample(1:K, 1)
    } else if(policy == "greedy") {
      a_t <- which.max(mu_hat)
    } else if(policy == "eps_greedy") {
      if(runif(1) < epsilon) {
        a_t <- sample(1:K, 1)
      } else {
        a_t <- which.max(mu_hat)
      }
    } else if(policy == "ucb") {
      # Adaptando UCB para variância da posteriori Gamma: Var = alpha / beta^2
      # Usando limite superior aproximado
      std_dev <- sqrt(alpha_t / (beta_t^2))
      ucb_score <- mu_hat + 2 * std_dev
      a_t <- which.max(ucb_score)
    } else if(policy == "ts") {
      # Thompson Sampling: amostragem da priori conjugada Gamma
      lambda_sample <- rgamma(K, shape = alpha_t, rate = beta_t)
      a_t <- which.max(lambda_sample)
    }
    
    r <- rpois(1, lambda_true[a_t])
    rewards[t] <- r
    actions[t] <- a_t
    
    # Atualização conjugada
    alpha_t[a_t] <- alpha_t[a_t] + r
    beta_t[a_t] <- beta_t[a_t] + 1
  }
  
  return(data.frame(t = 1:T_steps, policy = policy, reward = rewards, action = actions))
}

policies_p2 <- c("uniform", "greedy", "eps_greedy", "ucb", "ts")
n_sims_p2 <- 100

resultados_p2 <- bind_rows(lapply(policies_p2, function(p) {
  sims <- lapply(1:n_sims_p2, function(i) {
    df <- simular_poisson_bandit(T_steps = 1000, policy = p)
    df$sim_id <- i
    df$cum_reward <- cumsum(df$reward)
    return(df)
  })
  bind_rows(sims)
}))

resumo_tempo_p2 <- resultados_p2 %>%
  group_by(policy, t) %>%
  summarise(mean_cum_reward = mean(cum_reward),
            lower_ci = quantile(cum_reward, 0.05),
            upper_ci = quantile(cum_reward, 0.95),
            .groups = 'drop')

ggplot(resumo_tempo_p2, aes(x = t, y = mean_cum_reward, color = policy, fill = policy)) +
  geom_line(size = 1) +
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci), alpha = 0.2, color = NA) +
  theme_minimal() +
  labs(title = "Comparação de Recompensas Acumuladas",
       x = "Passo de Tempo (t)", y = "Recompensa Acumulada") +
  theme(legend.position = "bottom")