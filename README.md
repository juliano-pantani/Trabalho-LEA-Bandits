# 🎰 Análise de Algoritmos de Multi-Armed Bandits (MAB)

Trabalho acadêmico de **Pedro Ricardo Binhardi** e **Juliano Parasmo Pantani**, desenvolvido para a disciplina de LEA, sobre o problema de *Multi-Armed Bandits*. O repositório reúne simulações em R que investigam duas questões centrais no uso de políticas adaptativas: o viés estatístico introduzido na inferência pós-seleção e o desempenho dessas políticas na maximização de recompensas.

## 📁 Estrutura do Repositório

| Arquivo | Descrição |
|---|---|
| `codigos_projetobandit.R` | Script principal com toda a simulação (Partes 1 e 2) |
| `RelatórioBandits_PRB.Rmd` | Relatório em R Markdown com a análise completa |
| `RelatórioBandits_PRB.html` | Versão renderizada (HTML) do relatório |

## 🧪 O que o projeto investiga

O trabalho está dividido em duas partes, cada uma comparando quatro (ou cinco) políticas clássicas de bandit: **Uniforme (aleatória)**, ***Greedy***, **UCB** e **Thompson Sampling** (e, na Parte 2, também **ε-Greedy**).

### Parte 1 — Viés de Seleção e Cobertura de Intervalos de Confiança

- **Pergunta:** quando o "melhor braço" é escolhido adaptativamente ($\hat{a} = \arg\max \hat{\mu}_a$), o IC de 95% construído para ele ainda tem cobertura de 95%?
- **Setup:** 5 braços gaussianos com médias verdadeiras iguais a zero ($\mu_1=\dots=\mu_5=0$), simulação de Monte Carlo com $T=500$ passos e 1000 réplicas por política.
- **Resultado:** políticas adaptativas (Greedy, UCB, TS) subestimam a incerteza real e **violam a cobertura nominal**, evidenciando o efeito do viés de seleção — o braço "vencedor" tende a ter sua média superestimada.

### Parte 2 — Otimização de Recompensa em Ambiente Poisson

- **Pergunta:** qual política acumula mais recompensa ao equilibrar exploração e explotação?
- **Setup:** 5 braços com recompensas Poisson de taxas $\lambda_a \in \{18, 20, 21, 23, 27\}$, priori conjugada Gamma$(2, 0.1)$, $T=1000$ passos e 100 réplicas por política.
- **Resultado:** **Thompson Sampling** e **UCB** superam claramente as estratégias mais simples (Uniforme, Greedy, ε-Greedy) em recompensa acumulada, mostrando o valor de balancear exploração e explotação de forma adaptativa.

## ⚙️ Como rodar

O código foi desenvolvido em **R**. Instale as dependências:

```r
install.packages(c("tidyverse", "patchwork", "knitr"))
```

Em seguida, execute o script principal:

```r
source("codigos_projetobandit.R")
```

Ou abra e renderize o relatório completo:

```r
rmarkdown::render("RelatórioBandits_PRB.Rmd")
```

## 📊 Saídas geradas

- Tabela de cobertura empírica e média estimada do braço selecionado (Parte 1)
- Gráfico de densidade da média do braço vencedor por política (Parte 1)
- Gráfico de recompensa acumulada média (com bandas de intervalo de 90%) ao longo do tempo, por política (Parte 2)

## 📚 Referências conceituais

O trabalho se apoia na literatura clássica de bandits (UCB, Thompson Sampling) e na discussão sobre inferência pós-seleção em experimentos adaptativos.
