#=====================================================================
# Opens Wlprinter window
# Copyright (c) 2010
#
#  Author: Tekki
#     Web: http://www.tekki.ch
#
#  Version: 1.0
#
#======================================================================
1;

#---------------------------------------
sub open {

  my $wllink = qx|/usr/local/wlprinter/bin/getlink.pl $form->{login}|;

  $form->{title} = 'WLprinter';
  $form->header;
  print qq|<head>
</head>
<body>
  <table width=100%>
    <tr>
      <th class=listtop>$form->{title}</th>
    </tr>
  </table>
  <script type="text/javascript">
    window.location.href="../$wllink";
  </script>
</body>
</html>
|;
}

#---------------------------------------

#######################
#
# EOF: wlprinter.pl
#
#######################

