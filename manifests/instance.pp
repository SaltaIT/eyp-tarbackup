#
define tarbackup::instance(
                            $destination,
                            $includedir,
                            $backupname   = 'Files',
                            $excludedir   = undef,
          				          $retention    = undef,
          				          $logdir       = undef,
                            $mailto       = undef,
                            $idhost       = undef,
                            $hour         = '2',
                            $minute       = '0',
                            $month        = undef,
                            $monthday     = undef,
                            $weekday      = undef,
                            $setcron      = true,
                            $xdev         = false,
                          ){
  #
  include ::tarbackup

  file { "${tarbackup::basedir}/${tarbackup::backupscript}_${name}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/tarbackupconfig.erb"),
  }

  if($setcron)
  {
    cron { "cronjob tarball backup ${tarbackup::backupscript}":
      command  => "${tarbackup::basedir}/${tarbackup::backupscript}.sh ${tarbackup::basedir}/${tarbackup::backupscript}_${name}.config",
      user     => 'root',
      hour     => $hour,
      minute   => $minute,
      month    => $month,
      monthday => $monthday,
      weekday  => $weekday,
      require  => File[ [ "${tarbackup::basedir}/${tarbackup::backupscript}_${name}.config", "${tarbackup::basedir}/${tarbackup::backupscript}.sh" ] ],
    }
  }

}
