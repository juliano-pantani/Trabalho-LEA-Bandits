# Análise de Algoritmos de Multi-Armed Bandits (MAB)

Este repositório contém a implementação e a análise estatística de experimentos baseados em problemas de *Multi-Armed Bandits* (MAB), abrangendo tanto a inferência estatística sob viés de seleção quanto a otimização de recompensas em cenários adaptativos.

## Estrutura do Projeto

O trabalho está estruturado em duas vertentes principais:

1.  **Parte 1: Viés de Seleção e Intervalos de Confiança**
    *   **Objetivo:** Avaliar a cobertura empírica de intervalos de confiança (IC) nominais de 95% para o braço selecionado como o melhor ($\hat{a} = \arg\max \hat{\mu}_a$).
    *   **Metodologia:** Simulação de Monte Carlo com $T=500$ passos, comparando políticas de seleção (Uniforme, *Greedy*, UCB e *Thompson Sampling*) sob a hipótese nula ($\mu_1 = \dots = \mu_5 = 0$).
    *   **Conclusão:** Evidencia-se a subestimação da incerteza e a violação da cobertura nominal devido ao viés de seleção inerente a políticas adaptativas.

2.  **Parte 2: Otimização de Recompensas (Modelo Poisson)**
    *   **Objetivo:** Maximizar a recompensa acumulada em um ambiente estocástico, modelado via distribuição Poisson com taxas $\lambda_a$.
    *   **Metodologia:** Implementação de políticas de exploração-explotação e análise da eficiência acumulada ao longo de $T=1000$ períodos.
    *   **Conclusão:** Demonstra-se a superioridade das estratégias de *Thompson Sampling* e UCB no equilíbrio entre exploração e explotação, contrastando com a rigidez da estratégia *Greedy*.

## Requisitos de Execução

O código foi desenvolvido na linguagem **R**. Para a replicação dos resultados, é necessária a instalação dos seguintes pacotes:

```r
install.packages(c("tidyverse", "patchwork", "knitr"))
