#
class tarbackup (
                  $includedir,
                  $destination,
                  $basedir="/usr/local/bin",
                  $backupscript="tarbackup",
                  $backupname="Files",
                  $excludedir=undef,
				          $retention=undef,
				          $logdir=undef,
                  $mailto=undef,
                  $idhost=undef,
                  $hour='2',
                  $minute='0',
                  $month=undef,
                  $monthday=undef,
                  $weekday=undef,
                  $setcron=true,
                ){
  #
  file { "${basedir}/${backupscript}.sh":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template("${module_name}/tarbackup.erb"),
  }

  file { "${basedir}/${backupscript}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/tarbackupconfig.erb"),
  }

  if($setcron)
  {
    cron { "cronjob tarball backup ${backupscript}":
      command  => "${basedir}/${backupscript}.sh",
      user     => 'root',
      hour     => $hour,
      minute   => $minute,
      month    => $month,
      monthday => $monthday,
      weekday  => $weekday,
      require  => File[ [ "${basedir}/${backupscript}.config", "${basedir}/${backupscript}.sh" ] ],
    }
  }

}
