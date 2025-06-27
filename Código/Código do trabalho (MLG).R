library(PNSIBGE) # Obtenção da base do PNS (Pesquisa Nacional de Saude)
library(ResourceSelection)
library(pROC)
library(dplyr)
library(ggplot2)
library(performance)
library(ggeffects)
library(DHARMa)  # Para diagnóstico gráfico de resíduos
library(MASS)
library(glmnet)
library(patchwork)

dadosPNS_brutos <- get_pns(year=2019, vars=c("C006","Q055012", "P050" , "P027" , "P00104" , "Q00201", "Q03001", "C008", "C009"), design=FALSE)


# 1º Arrumando a Base de Dados

# Selecionar e renomear as colunas de interesse (279.382 observações)
dados <- dadosPNS_brutos %>% 
  dplyr::select(C006, P050, P027, P00104, Q00201, Q03001, C008, C009, Q055012) %>% 
  dplyr::rename(
    Sexo = C006,
    Fumar = P050,
    Alcool = P027,
    Peso = P00104,
    Hipertensao = Q00201,
    Diabetes = Q03001,
    Idade = C008,
    Cor_Raca = C009,
    AVC = Q055012
  )

# Apenas registros completos na variável AVC (6.326 Observações)
dados <- dados %>% 
  filter(!is.na(AVC))

summary(dados$Peso) # 11 NA's
summary(dados$Hipertensao) # 4 NA's

# Resolvi tira-los pois são poucos NA's (6.311 Observações)
dados <- dados %>% 
  filter(!is.na(Peso))
dados <- dados %>% 
  filter(!is.na(Hipertensao))

# Tirando as variáveis onde não tem informação
dados$AVC <- droplevels(dados$AVC)
dados$Alcool <- droplevels(dados$Alcool)
dados$Fumar <- droplevels(dados$Fumar)
dados$Hipertensao <- droplevels(dados$Hipertensao)
dados$Cor_Raca <- droplevels(dados$Cor_Raca)
dados$Diabetes <- droplevels(dados$Diabetes)

summary(dados$AVC)

# 2º Análise Exploratória

# Tabelas de Frequência
cat_vars <- names(dados)[sapply(dados, is.factor) | sapply(dados, is.character)]
plot_list <- list()  # Lista para armazenar os gráficos

for (var in cat_vars) {
  if (var != "AVC") {
    freq_df <- as.data.frame(table(dados[[var]], dados$AVC))
    colnames(freq_df) <- c("Categoria", "AVC", "Frequencia")
    
    p <- ggplot(freq_df, aes(x = Categoria, y = Frequencia, fill = AVC)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
      geom_text(aes(label = Frequencia), 
                position = position_dodge(width = 0.9), 
                vjust = -0.3, size = 3.5) +
      labs(title = paste("Distribuição de", var, "por AVC"),
           x = var,
           y = "Frequência") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    plot_list[[var]] <- p
  }
}

# Número de gráficos por página
n_por_pagina <- 4
n_total <- length(plot_list)
paginas <- ceiling(n_total / n_por_pagina)

for (i in 1:paginas) {
  inicio <- (i - 1) * n_por_pagina + 1
  fim <- min(i * n_por_pagina, n_total)
  
  # Seleciona os gráficos da vez
  graficos <- plot_list[inicio:fim]
  
  # Usa patchwork para combinar (automaticamente 2x2)
  combinado <- wrap_plots(graficos, ncol = 2)
  print(combinado)
}

# Boxplots das variáveis numéricas em relação a AVC
num_vars <- names(dados)[sapply(dados, is.numeric)]

# Gera todos os boxplots e guarda em uma lista
plots <- lapply(num_vars, function(var) {
  ggplot(dados, aes(x = as.factor(AVC), y = .data[[var]])) +
    geom_boxplot() +
    labs(title = paste("Boxplot de", var, "por AVC"),
         x = "AVC",
         y = var) +
    theme_minimal()
})

# Função para combinar os plots
num_plots <- length(plots)
for (i in seq(1, num_plots, by = 4)) {
  group <- plots[i:min(i+3, num_plots)]  # Pega até 4 plots
  if (length(group) == 4) {
    print((group[[1]] | group[[2]]) / (group[[3]] | group[[4]]))
  } else if (length(group) == 3) {
    print((group[[1]] | group[[2]]) / group[[3]])
  } else if (length(group) == 2) {
    print(group[[1]] | group[[2]])
  } else {
    print(group[[1]])
  }
} 

# 3º Modelo
# Normalizar (escalar para média 0 e desvio 1) Apenas Peso e Idade
dados_norm <- dados %>% 
  mutate(
    Peso = scale(Peso),
    Idade = scale(Idade)
  )


dados_norm$Idade <- as.numeric(scale(dados_norm$Idade))
dados_norm$Peso <- as.numeric(scale(dados_norm$Peso))

# Ajustar o modelo (A variável "Diabetes" foi retirada por ter somente uma classe: Todos os pacientes tinha diabetes)
modelo <- glm(AVC ~ Fumar + Alcool + Peso + Sexo + Hipertensao + Idade + Cor_Raca,
              data = dados_norm, 
              family = "binomial")

summary(modelo)

# Usando Step
modelo_step = stepAIC(modelo, direction = "both")

summary(modelo_step)

# OR
odds_ratios_padr <- exp(cbind(OR = coef(modelo_step), confint(modelo_step)))

odds_ratios_padr

# Análise Residual
check_model(modelo)

# verificar Cook's Distance:
#influencia <- influence.measures(modelo_step)
#cooks <- cooks.distance(modelo_step)
#plot(cooks, main = "Cook's Distance")
#abline(h = 4 * mean(cooks), col = "red", lty = 2)  # ponto de corte

#influentes <- which(cooks > 4/length(cooks))
#influentes
# Nesta parte, eu fiquei em dúvida de como prosseguir, pois teve muitos valores influentes, e se eu excluir, o modelo fica muito ruim. Talvez eu tenha feito errado.

# Teste de Hoslem (Ajuste)
dados_norm$AVC_bin <- ifelse(dados_norm$AVC == "Sim", 1, 0)

hosmer <- hoslem.test(dados_norm$AVC_bin, fitted(modelo_step))
hosmer

# Curva Hoc
pred <- predict(modelo_step, type = "response")
roc_obj <- roc(dados_norm$AVC, pred)

plot(roc_obj, main = "Curva ROC")
cat("AUC =", auc(roc_obj), "\n")

# Gráfico dos efeitos:
ggpredict(modelo_step) %>%
  plot()

# Matriz de Confusão

# Prever probabilidades no conjunto de dados de treinamento
pred_prob <- predict(modelo_step, newdata = dados_norm, type = "response")

summary(pred_prob)

# Transformar em 0 ou 1 a partir de um ponto de corte (aqui 0.9361, pelo summary, achei melhor usar a média/mediana)
pred_classes <- ifelse(pred_prob > 0.9361, "Sim", "Não")

conf_matrix <- confusionMatrix(as.factor(pred_classes),
                               as.factor(dados_norm$AVC))
print(conf_matrix)

# Transformar para um data frame
mat_df <- as.data.frame(conf_matrix$table)
names(mat_df) <- c("Referencia", "Predito", "Frequencia")

# Plotar o heatmap da matriz de confusão
ggplot(mat_df, aes(x = Predito, y = Referencia, fill = Frequencia)) + 
  geom_tile() + 
  geom_text(aes(label = Frequencia), color = "black", size = 5) + 
  scale_fill_gradient(low = "gold", high = "purple") + 
  labs(title = "Matriz de Confusão",
       x = "Valor Previsto",
       y = "Valor Real")
