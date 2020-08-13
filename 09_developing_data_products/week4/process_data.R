# read_rds("data/os_bons.rds") %>%
#     filter(me != "Eu") %>%
#     select(-me) %>%
#     mutate(across(starts_with("TP_"), as.factor)) %>%
#     mutate(TP_COR_RACA = case_when(
#         TP_COR_RACA == 0 ~ "Not Declared",
#         TP_COR_RACA == 1 ~ "White",
#         TP_COR_RACA == 2 ~ "Black",
#         TP_COR_RACA == 3 ~ "Multiracial",
#         TP_COR_RACA == 4 ~ "Asian",
#         TP_COR_RACA == 5 ~ "Indigenous"
#     )) %>%
#     mutate(TP_ESTADO_CIVIL = case_when(
#         TP_ESTADO_CIVIL == 0 ~ "Not Declared",
#         TP_ESTADO_CIVIL == 1 ~ "Single",
#         TP_ESTADO_CIVIL == 2 ~ "Married",
#         TP_ESTADO_CIVIL == 3 ~ "Divorced"
#     )) %>%
#     mutate(TP_NACIONALIDADE = case_when(
#         TP_NACIONALIDADE == 0 ~ "Not Declared",
#         TP_NACIONALIDADE == 1 ~ "Brazilian",
#         TP_NACIONALIDADE == 2 ~ "Brazilian (Naturalized)",
#         TP_NACIONALIDADE == 3 ~ "Foreigner",
#         TP_NACIONALIDADE == 4 ~ "Brazilian (born outside the Contry)"
#     )) %>%
#     mutate(TP_ESCOLA = case_when(
#         TP_ESCOLA == 1 ~ "Not Declared",
#         TP_ESCOLA == 2 ~ "Public",
#         TP_ESCOLA == 3 ~ "Private",
#         TP_ESCOLA == 4 ~ "School in other Country"
#     )) %>%
#     mutate(TP_SEXO = case_when(
#         TP_SEXO == "M" ~ "Male",
#         TP_SEXO == "F" ~ "Female"
#     )) %>%
#     mutate(TP_LINGUA = case_when(
#         TP_LINGUA == 0 ~ "English",
#         TP_LINGUA == 1 ~ "Spanish"
#     )) %>%
#     mutate(
#         TP_ESTADO_CIVIL = fct_relevel(TP_ESTADO_CIVIL, "Not Declared", after = Inf),
#         TP_COR_RACA = fct_relevel(TP_COR_RACA, "Not Declared", after = Inf),
#         TP_ESCOLA = fct_relevel(TP_ESCOLA, "Not Declared", after = Inf)) -> enem_small
# enem_small %>% glimpse()
# write_rds(enem_small, "data/enem.rds")

enem_df %>%
    filter(me != "Eu") %>%
    select(-me) %>%
    mutate(across(starts_with("TP_"), as.factor)) %>%
    mutate(TP_COR_RACA = case_when(
        TP_COR_RACA == 0 ~ "Não Declarado",
        TP_COR_RACA == 1 ~ "Branca",
        TP_COR_RACA == 2 ~ "Preta",
        TP_COR_RACA == 3 ~ "Parda",
        TP_COR_RACA == 4 ~ "Amarela",
        TP_COR_RACA == 5 ~ "Indígena"
    )) %>%
    mutate(NU_IDADE = as.factor(NU_IDADE)) %>%

enem_small %>%
    ggplot() +
    geom_histogram(aes(NU_NOTA_MT, fill = NU_IDADE)) +
    facet_wrap(~ SG_UF_RESIDENCIA)

