# 🧠 Modelagem de Fatores Associados ao AVC com Regressão Logística

Este projeto tem como objetivo analisar os fatores associados ao Acidente Vascular Cerebral (AVC) utilizando **Modelos Lineares Generalizados (Regressão Logística)**. A base de dados utilizada foi a **Pesquisa Nacional de Saúde (PNS) - 2019**, permitindo uma avaliação populacional dos riscos relacionados ao AVC no Brasil.

## 📚 Sobre o Projeto

O AVC é uma das principais causas de morte e incapacidade no mundo. Este trabalho busca investigar, por meio da regressão logística, como variáveis sociodemográficas e de estilo de vida podem influenciar a ocorrência do AVC.

O foco da modelagem foi analisar a relação entre a ocorrência de AVC (variável resposta binária) e as seguintes variáveis explicativas:
- Sexo
- Idade
- Peso
- Hipertensão
- Tabagismo
- Consumo de Álcool
- Cor/Raça

---

## 🔎 Etapas Realizadas

- ✔️ **Análise Descritiva** das variáveis qualitativas e quantitativas.
- ✔️ **Ajuste do Modelo de Regressão Logística Completo.**
- ✔️ **Seleção de Variáveis via Stepwise.**
- ✔️ Avaliação das Odds Ratios (OR) para interpretação dos fatores de risco.
- ✔️ Validação do modelo com:
  - Matriz de Confusão
  - Acurácia, Sensibilidade e Especificidade
  - Curva ROC
  - Análise Residual e Diagnóstico de Multicolinearidade
- ✔️ Discussão sobre limitações, como desbalanceamento das classes e possíveis falhas de amostragem.

---

## 🛠️ Tecnologias Utilizadas

- `R` (Estatística e Visualização)
- Pacotes: `glm`, `ggplot2`, `pROC`, entre outros.

---

## 📂 Arquivos Disponíveis

- `MLG.R`: Código completo da análise.
- Relatório em PDF: Detalhamento da metodologia, resultados e conclusões.

---

## 📊 Principais Resultados

- **Variáveis Significativas:**
  - Consumo de Álcool
  - Sexo (Mulher)
  - Hipertensão (resultado contrário ao esperado, possível viés de amostragem)
  - Idade (resultado contrário ao esperado, pode estar relacionado ao viés de resposta)

- **Desempenho do Modelo:**
  - Acurácia: 47,81%
  - AUC: 0,64
  - O modelo teve baixa capacidade de classificação, especialmente para casos positivos (AVC).

- **Principais Limitações:**
  - Desbalanceamento da variável resposta (maioria dos indivíduos não tiveram AVC).
  - Possíveis falhas de amostragem e viés de seleção.

---

## 🚀 Próximos Passos

- Aplicar **modelos mais robustos** como Florestas Aleatórias e Árvores de Decisão.
- Considerar técnicas de balanceamento de classes (oversampling/undersampling).
- Explorar novas variáveis que podem contribuir para um modelo mais explicativo.

---

## 📎 Referências

- Ministério da Saúde: [AVC - Acidente Vascular Cerebral](https://bvsms.saude.gov.br/avc-acidente-vascular-cerebral/)
- Pesquisa Nacional de Saúde (PNS): [PNS - Fiocruz](https://www.pns.icict.fiocruz.br/)
- Hastie, Tibshirani & Friedman. *The Elements of Statistical Learning*.
- Hosmer, Lemeshow & Sturdivant. *Applied Logistic Regression*.

---

Desenvolvido por **Thaii Céu Santos** ✨
