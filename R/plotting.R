# minttea_module = minttea_results$`keep_10//des_0.5//nrep_10//nfol_5//ncom_5//edge_0.8`$module1
plot_module_with_igraph <- function(minttea_module, prefix_colors = c('T' = 'darkred','P' = 'darkgreen', 'M' = 'purple4')) {
  require(igraph)
  nodes <- data.frame(node = minttea_module$features) %>%
    mutate(prefix = gsub('__.*$','',node)) %>%
    mutate(color = prefix_colors[prefix])
  edges <- minttea_module$module_edges %>%
    mutate(width = edge_weight)
  g <- graph_from_data_frame(edges, directed=F, vertices = nodes)
  plot(g, vertex.label.cex = 0.8, vertex.label.dist = -2, vertex.label.color = 'black', edge.color = 'grey80')
}

plot_module_stats <- function(minttea_results, settings, module) {
  require(dplyr)
  require(ggplot2)

  tmp <- data.frame(AUC = minttea_results[[settings]][[module]]$shuffled_auroc, Mode = 'Null')
  tmp$Mode <- factor(tmp$Mode, levels = c('Null', 'True module'))
  true_auc <- minttea_results[[settings]][[module]]$auroc
  p1 <- ggplot(tmp, aes(fill = Mode, x = AUC)) +
    geom_histogram(color = 'black', bins = 20) +
    scale_fill_manual(values = c('Null' = 'grey80', 'True module' = 'orangered3'), drop = FALSE) +
    scale_y_continuous(expand = c(0,0)) +
    geom_vline(color = 'orangered3', xintercept = true_auc, linewidth = 2) +
    ylab('Count') +
    xlab("AUC of module's 1st PC") +
    theme_classic() +
    theme(legend.title = element_blank())

  tmp <- data.frame(Cross_Omic_Correlation = minttea_results[[settings]][[module]]$shuffled_inter_view_corr, Mode = 'Null')
  tmp$Mode <- factor(tmp$Mode, levels = c('Null', 'True module'))
  true_cor <- minttea_results[[settings]][[module]]$inter_view_corr
  p2 <- ggplot(tmp, aes(fill = Mode, x = Cross_Omic_Correlation)) +
    geom_histogram(color = 'black', bins = 20) +
    scale_fill_manual(values = c('Null' = 'grey80', 'True module' = 'orangered3'), drop = FALSE) +
    scale_y_continuous(expand = c(0,0)) +
    geom_vline(color = 'orangered3', xintercept = true_cor, linewidth = 2) +
    ylab('Count') +
    xlab('Avg. correlation between\nfeatures cross-omic') +
    theme_classic() +
    theme(legend.title = element_blank())

  return(list(p1 = p1, p2 = p2))
}

# TODO:
# plot_modules_overview <- function(minttea_output,
#                               feature_type_color_map) {
#
#   # ---- Strip 1: N features per dataset per module ---->
#   tmp1 <- sens_analysis_modules %>%
#     mutate(feature_type = substr(feature,1,1)) %>%
#     mutate(module = as.numeric(gsub('module', '', module))) %>%
#     group_by(dataset, module, feature_type) %>%
#     summarise(N = n(), .groups = "drop")
#
#   # Only plot modules with at least 2 types of features
#   modules_to_plot <- modules_overview %>%
#     filter(multi_view) %>%
#     select(dataset, module, is_interesting) %>%
#     mutate(module = as.numeric(gsub('module','',module)))
#
#   tmp1 <- inner_join(tmp1, modules_to_plot, by = c('dataset','module'))
#
#   tmp1$module2 <- factor(paste('Module', tmp1$module),
#                          levels = paste('Module', max(tmp1$module):1))
#
#   p1 <- ggplot(tmp1 %>%
#                  filter(dataset %in% dataset_order) %>%
#                  mutate(dataset = factor(dataset, levels = dataset_order)),
#                aes(x = module2, y = N, fill = feature_type)) +
#     geom_rect(data = tmp1 %>%
#                 filter(dataset %in% dataset_order) %>%
#                 mutate(dataset = factor(dataset, levels = dataset_order)) %>%
#                 select(dataset) %>%
#                 distinct(),
#               aes(alpha = dataset %>% as.numeric() %% 2 == 0),
#               xmin = -Inf,
#               xmax = Inf,
#               ymin = -Inf,
#               ymax = Inf,
#               fill = 'gray80',
#               inherit.aes = FALSE) +
#     scale_alpha_manual(values = c('FALSE' = 0, 'TRUE' = 0.3), guide = "none") +
#     new_scale("alpha") +
#     geom_bar(aes(alpha = is_interesting, color = is_interesting),
#              width = 0.8,
#              position="stack",
#              stat="identity") +
#     scale_alpha_manual(values = c('FALSE' = 0.3, 'TRUE' = 0.9), guide = "none") +
#     scale_color_manual(values = c('FALSE' = 'gray70', 'TRUE' = 'black'), guide = "none") +
#     geom_hline(yintercept = 0) +
#     scale_y_continuous(expand = c(0, 0, 0.1, 0)) +
#     scale_x_discrete(expand = c(0, 0.5)) +
#     coord_flip() +
#     theme_classic() +
#     facet_grid(rows = vars(dataset), space = "free_y", scales = "free_y", switch = "y") +
#     xlab(NULL) +
#     ylab("No. of features\nof each type") +
#     scale_fill_manual(name = "View", values = feature_type_color_map) +
#     theme(panel.grid.major.x =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(panel.grid.minor.x = element_blank()) +
#     theme(panel.grid.major.y =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(axis.text.y = element_text(size = 9)) +
#     theme(legend.position = "none") +
#     theme(axis.title.x = element_text(size = 11)) +
#     theme(strip.background = element_blank()) +
#     theme(strip.placement = "outside") +
#     theme(strip.text.y.left = element_text(size = 10, angle = 0, hjust = 1)) +
#     theme(panel.spacing.y = unit(6, "points"))
#
#   if (hide_y_axis_text) p1 <- p1 + theme(axis.text.y = element_blank())
#
#   # ---- Strip 3: AUC ---->
#   tmp2 <- modules_overview %>%
#     select(-is_interesting) %>%
#     mutate(module = as.numeric(gsub('module','',module))) %>%
#     inner_join(modules_to_plot, by = c('dataset','module'))
#
#   tmp2$module2 <- factor(paste('Module', tmp2$module),
#                          levels = levels(tmp1$module2))
#   points_size <- ifelse(hide_y_axis_text, 3, 3.7)
#
#   p2 <- ggplot(tmp2 %>%
#                  filter(dataset %in% dataset_order) %>%
#                  mutate(dataset = factor(dataset, levels = dataset_order)),
#                aes(x = module2)) +
#     geom_rect(data = tmp1 %>%
#                 filter(dataset %in% dataset_order) %>%
#                 mutate(dataset = factor(dataset, levels = dataset_order)) %>%
#                 select(dataset) %>%
#                 distinct(),
#               aes(alpha = dataset %>% as.numeric() %% 2 == 0),
#               xmin = -Inf,
#               xmax = Inf,
#               ymin = -Inf,
#               ymax = Inf,
#               fill = 'gray80',
#               inherit.aes = FALSE) +
#     scale_alpha_manual(values = c('FALSE' = 0, 'TRUE' = 0.3), guide = "none") +
#     geom_hline(yintercept = 0.5, color = "darkred", linetype = "dashed", linewidth = 1) +
#     # Shuffled standard deviations
#     geom_linerange(aes(ymax = mean_module_auc_shuffled + sd_module_auc_shuffled,
#                        ymin = mean_module_auc_shuffled - sd_module_auc_shuffled),
#                    alpha = 0.4, linewidth = 2, color = "grey70") +
#     # Shuffled AUCs
#     geom_point(aes(y = mean_module_auc_shuffled),
#                shape = 16, size = points_size - 0.5,
#                color = 'grey60', alpha = 0.8) +
#     # True standard deviations
#     # geom_linerange(aes(ymax = sdev_high_, ymin = sdev_low_, color = feature_set_type),
#     #                position = position_dodge(width = p3_dodging),
#     #                alpha = 0.35, linewidth = 2) +
#     # True AUCs
#     geom_point(aes(y = mean_module_auc, fill = is_interesting, color = is_interesting),
#                shape = 23,
#                size = points_size, alpha = 0.9) +
#     scale_fill_manual(values = c('FALSE' = '#D7E7ED', 'TRUE' = 'skyblue4'), guide = "none") +
#     scale_color_manual(values = c('FALSE' = 'gray60', 'TRUE' = 'black'), guide = "none") +
#     scale_y_continuous(breaks = seq(0.5,1,0.1), expand = expansion(mult = c(0.05,0.1))) +
#     scale_x_discrete(expand = c(0, 0.5)) +
#     coord_flip() +
#     theme_classic() +
#     xlab(NULL) +
#     ylab("Module AUC") +
#     facet_grid(rows = vars(dataset), space = "free_y", scales = "free_y", switch = "y") +
#     theme(panel.grid.major.x =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(panel.grid.major.y =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(axis.title.x = element_text(size = 11)) +
#     theme(axis.text.y = element_blank()) +
#     theme(strip.background = element_blank(), strip.text = element_blank()) +
#     theme(panel.spacing.y = unit(6, "points"))
#
#   if (show_rf) p2 <- p2 + geom_hline(aes(yintercept = mean_auc_rf), color = "goldenrod2", linewidth = 2, alpha = 0.7)
#
#   # ---- Strip 2: Cross-view correlations ---->
#   p3 <- ggplot(tmp2 %>%
#                  filter(dataset %in% dataset_order) %>%
#                  mutate(dataset = factor(dataset, levels = dataset_order)),
#                aes(x = module2)) +
#     geom_rect(data = tmp1 %>%
#                 filter(dataset %in% dataset_order) %>%
#                 mutate(dataset = factor(dataset, levels = dataset_order)) %>%
#                 select(dataset) %>%
#                 distinct(),
#               aes(alpha = dataset %>% as.numeric() %% 2 == 0),
#               xmin = -Inf, xmax = Inf, ymin = -Inf,
#               ymax = Inf, fill = 'gray80', inherit.aes = FALSE) +
#     scale_alpha_manual(values = c('FALSE' = 0, 'TRUE' = 0.3), guide = "none") +
#     # Shuffled standard deviations
#     geom_linerange(aes(ymax = avg_spear_corr_shuffled + sd_spear_corr_shuffled,
#                        ymin = avg_spear_corr_shuffled - sd_spear_corr_shuffled),
#                    alpha = 0.4, linewidth = 2, color = "grey70") +
#     # Shuffled correlations
#     geom_point(aes(y = avg_spear_corr_shuffled),
#                shape = 16, size = points_size - 0.5, color = 'grey60', alpha = 0.8) +
#     geom_point(aes(y = avg_spear_corr, fill = is_interesting, color = is_interesting),
#                shape = 23,
#                size = points_size,
#                alpha = 0.9) +
#     scale_fill_manual(values = c('FALSE' = '#D9B9AB', 'TRUE' = 'sienna4'), guide = "none") +
#     scale_color_manual(values = c('FALSE' = 'gray60', 'TRUE' = 'black'), guide = "none") +
#     scale_x_discrete(expand = c(0, 0.5)) +
#     scale_y_continuous(expand = expansion(mult = c(0.05,0.1))) +
#     coord_flip() +
#     theme_classic() +
#     xlab(NULL) +
#     ylab("Cross-view avg.\ncorrelation") +
#     facet_grid(rows = vars(dataset), space = "free_y", scales = "free_y", switch = "y") +
#     theme(panel.grid.major.x =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(panel.grid.major.y =
#             element_line(linewidth = 0.5, color = "grey93")) +
#     theme(axis.title.x = element_text(size = 11)) +
#     theme(axis.text.y = element_blank()) +
#     theme(strip.background = element_blank(), strip.text = element_blank()) +
#     theme(panel.spacing.y = unit(6, "points"))
#
#   # Combine plots
#   tmp_rel_widths <- c(8.1, 3, 3)
#   if (hide_y_axis_text) tmp_rel_widths <- c(7, 3, 3)
#   print(plot_grid(p1, p3, p2,
#                   nrow = 1,
#                   rel_widths = tmp_rel_widths,
#                   align = 'h', axis = 'tb'))
# }
