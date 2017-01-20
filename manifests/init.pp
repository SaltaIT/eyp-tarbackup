#
class tarbackup (
                  $basedir      = '/usr/local/bin',
                  $backupscript = 'tarbackup',
                ){

  file { "${basedir}/${backupscript}.sh":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template("${module_name}/tarbackup.erb"),
  }

}
