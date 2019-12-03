function vers = eegplugin_runica_nsg(fig,  try_strings, catch_strings)
vers = '0.1';
plotmenu = findobj(fig, 'tag', 'tools');
submenu = uimenu( plotmenu, 'Label', 'Run ICA via the OEP', 'separator', 'on', 'callback',...
    [try_strings.no_check '[EEG]=pop_runica_nsg(EEG);' catch_strings.add_to_hist]);
