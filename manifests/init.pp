#
class tarbackup (
                  $basedir      = '/usr/local/bin',
                  $backupscript = 'tarbackup',
                ) {

  file { "${basedir}/${backupscript}.sh":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => file("${module_name}/tarbackup.sh"),
  }

}
