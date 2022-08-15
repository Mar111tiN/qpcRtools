load_qPCR_data <- function(date=220222, device="7500", data_path="", dilution_factor=5, zero_step=2, ...){
  # load the qPCR data and apply dilution series
  std_path <- str_glue("{data_path}/std")

  file <- list.files(std_path) %>%
    as_tibble() %>%
    filter(grepl(date, value)) %>%
    filter(grepl(device, value))

  file_path <- str_glue("{std_path}/{file}")

  # read the file_path and wrangle data
  df <- read_excel(file_path, sheet="Results", range = cell_rows(c(8,NA))) %>%
    rename(sample = `Sample Name`, target = `Target Name`, CT = `Cт`) %>%
    filter(sample != "") %>%
    mutate(CT = as.numeric(na_if(CT, "Undetermined"))) %>%
    mutate(dilution = as.numeric(str_replace(str_replace(sample, " \\(NTC\\)$", ""), "STD", "")) -1) %>%
    mutate(conc = if_else(
        Task == "NTC", # condition
        1 / dilution_factor ** (dilution + zero_step),
        1 / dilution_factor ** (dilution)
    )) %>%
    select(c(sample,target, Task, CT, dilution, conc)) %>%
    return(df)
}

set_theme <- function(text.size=10, ...) {
    theme_light() +
    theme(
        axis.title.x = element_blank(),
        axis.text.x = element_text(size=text.size),
        plot.title = element_text(hjust=0.5),
        axis.text=element_text(size=text.size),
        axis.title = element_text(size=text.size)
    )
}


plot_qPCR_standard <- function(
  date = 220222,
  device = "7500",
  data_path = ".",
  protein = "",
  c = "",
  save_path = ".",
  ...
  ) {

  ########## LOAD DATA
    data <- load_qPCR_data(
      date = date,
      device = device,
      data_path = data_path,
      ...
      )
    if (protein != "") {
      data <- data %>%
        filter(target == protein)
      efficiency <- 10 **-(1/lm(data$CT ~log10(data$conc))$coefficients[2])
    }

    if (protein == "") {
      plot <- data %>%
        ggplot(aes(conc, CT, color=target)) +
        geom_point() +
        stat_smooth(method="lm", alpha=0.1, size=0.5)
    } else{
      # set the color
      c <- case_when(
        protein == "CXCR3 alt" ~ "darkgreen",
        protein == "HPRT" ~ "purple",
        protein == "CXCR3 A" ~ "red",
        protein == "CXCR3 B" ~ "cyan3",
        protein == "CD8" ~ "blue",
        protein == "CD247" ~ "orange",
        TRUE ~ "darkgray"
      )
      # plot extra stuff
      plot <- data %>%
        ggplot(aes(conc, CT)) +
        geom_point(color=c) +
        stat_smooth(method="lm", alpha=0.1, color=c, size=0.5)
    }
 
    plot <- plot +
    scale_x_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x)),
      limits = c(0.0001,1)
    ) +
    ylim(c(28,40)) +
    annotation_logticks(sides="b") +
    theme_light() +
    theme(plot.title = element_text(hjust=0.5)) +
    labs(
      x = "relative concentration (dilution series)",
      y = "CT value"
        )
  if (protein == "") {
    plot <- plot +
      ggtitle(str_glue("{date}@{device} - Standards")) +
      geom_rug(sides = "r") +
      set_theme(...)
  } else {
    plot <- plot +
      ggtitle(str_glue("{date}@{device} - {protein}-Standard")) +
      guides(color = "none") +
      geom_rug(sides = "r") +
      annotate(
        geom="text",
        label=str_glue("Eff = {round(efficiency,2)}"),
        x = 0.1,
        y = 38,
        size = 5
      ) + 
      set_theme(...)
  }
  if (save_path != "") {
    outpath <- str_glue("{save_path}/{date}-qPCR-{device}")
    if (protein != "") {
      outpath <- str_glue("{outpath}-{protein}")
    }
    outpath <- str_glue("{outpath}.pdf")
    ggsave(plot, filename = outpath)
  }
  return(plot)
}

load_ddPCR_data <- function(
    date=220222,
    device="ddPCR",
    protein="CXCR3alt",
    data_path=""
    ){
  # load the qPCR data and apply dilution series
  std_path <- str_glue("{data_path}/std")

  file <- list.files(std_path) %>%
    as_tibble() %>%
    filter(grepl(date, value)) %>%
    filter(grepl(device, value)) %>%
    filter(grepl(protein, value))

  drop.file <- str_glue("{std_path}/{file}") 
  read_csv(drop.file) %>%
    rename(dilution=`Sample description 1`, conc = `Conc(copies/µL)`) %>%
    select(dilution, conc) %>%
    mutate(dilution=(1/dilution))
}

plot_ddPCR_standard <- function (
    date=220222,
    device="ddPCR",
    protein="CXCR3alt",
    data_path="",
    save_path=""
) {
    plot <- load_ddPCR_data(
        date=date,
        device=device,
        protein=protein,
        data_path=data_path       
    ) %>%
   ggplot(aes(dilution, conc)) +
    scale_x_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      labels = scales::trans_format("log10", scales::math_format(10^.x)),
      limits = c(0.0001,1)
    ) +
    scale_y_log10() +
    stat_smooth(
      method="glm",
      #formula = y ~ x + I(x^2) + I((x^3),
      color="darkgray",
      fill="lightgray",
      size=.5
      ) +
   geom_point() +
   annotation_logticks() +
    geom_rug(sides="r") +
    theme_light() +
    theme(plot.title = element_text(hjust=0.5)) +
    labs(
      title=str_glue("ddPCR | ", {protein}, " standard"),
      x="relative concentration (dilution series)",
      y="absolute conc (copies/µl)"
    )

    if (save_path != "") {
        outpath <- str_glue("{save_path}/{date}-ddPCR")
    if (protein != "") {
      outpath <- str_glue("{outpath}-{protein}")
    }
    outpath <- str_glue("{outpath}.pdf")
    ggsave(plot, filename = outpath)
  }
  return(plot)
}
