#
define tarbackup::instance(
                            $destination,
                            $includedir,
                            $instancename = $name,
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
                            $s3bucket     = undef,
                            $prescript    = undef,
                            $postscript   = undef,
                            $gzip         = true,
                          ){
  #
  include ::tarbackup

  file { "${tarbackup::basedir}/${tarbackup::backupscript}_${instancename}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/tarbackupconfig.erb"),
  }

  if($setcron)
  {
    cron { "cronjob tarball backup ${tarbackup::backupscript}":
      command  => "${tarbackup::basedir}/${tarbackup::backupscript}.sh ${tarbackup::basedir}/${tarbackup::backupscript}_${instancename}.config",
      user     => 'root',
      hour     => $hour,
      minute   => $minute,
      month    => $month,
      monthday => $monthday,
      weekday  => $weekday,
      require  => File[ [ "${tarbackup::basedir}/${tarbackup::backupscript}_${instancename}.config", "${tarbackup::basedir}/${tarbackup::backupscript}.sh" ] ],
    }
  }

}
