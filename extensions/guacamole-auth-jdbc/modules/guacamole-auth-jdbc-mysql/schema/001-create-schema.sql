--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

--
-- Table of connection groups. Each connection group has a name.
--

CREATE TABLE `guacamole_connection_group` (

  `connection_group_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `parent_id`             int(11),
  `connection_group_name` varchar(128) NOT NULL,
  `type`                  enum('ORGANIZATIONAL',
                               'BALANCING') NOT NULL DEFAULT 'ORGANIZATIONAL',

  -- Concurrency limits
  `max_connections`          int(11),
  `max_connections_per_user` int(11),

  PRIMARY KEY (`connection_group_id`),
  UNIQUE KEY `connection_group_name_parent` (`connection_group_name`, `parent_id`),

  CONSTRAINT `guacamole_connection_group_ibfk_1`
    FOREIGN KEY (`parent_id`)
    REFERENCES `guacamole_connection_group` (`connection_group_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of connections. Each connection has a name, protocol, and
-- associated set of parameters.
-- A connection may belong to a connection group.
--

CREATE TABLE `guacamole_connection` (

  `connection_id`       int(11)      NOT NULL AUTO_INCREMENT,
  `connection_name`     varchar(128) NOT NULL,
  `parent_id`           int(11),
  `protocol`            varchar(32)  NOT NULL,
  
  -- Concurrency limits
  `max_connections`          int(11),
  `max_connections_per_user` int(11),

  PRIMARY KEY (`connection_id`),
  UNIQUE KEY `connection_name_parent` (`connection_name`, `parent_id`),

  CONSTRAINT `guacamole_connection_ibfk_1`
    FOREIGN KEY (`parent_id`)
    REFERENCES `guacamole_connection_group` (`connection_group_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of users. Each user has a unique username and a hashed password
-- with corresponding salt. Although the authentication system will always set
-- salted passwords, other systems may set unsalted passwords by simply not
-- providing the salt.
--

CREATE TABLE `guacamole_user` (

  `user_id`       int(11)      NOT NULL AUTO_INCREMENT,

  -- Username and optionally-salted password
  `username`      varchar(128) NOT NULL,
  `password_hash` binary(32)   NOT NULL,
  `password_salt` binary(32),

  -- Account disabled/expired status
  `disabled`      boolean      NOT NULL DEFAULT 0,
  `expired`       boolean      NOT NULL DEFAULT 0,

  -- Time-based access restriction
  `access_window_start`    TIME,
  `access_window_end`      TIME,

  -- Date-based access restriction
  `valid_from`  DATE,
  `valid_until` DATE,

  -- Timezone used for all date/time comparisons and interpretation
  `timezone` VARCHAR(64),

  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of connection parameters. Each parameter is simply a name/value pair
-- associated with a connection.
--

CREATE TABLE `guacamole_connection_parameter` (

  `connection_id`   int(11)       NOT NULL,
  `parameter_name`  varchar(128)  NOT NULL,
  `parameter_value` varchar(4096) NOT NULL,

  PRIMARY KEY (`connection_id`,`parameter_name`),

  CONSTRAINT `guacamole_connection_parameter_ibfk_1`
    FOREIGN KEY (`connection_id`)
    REFERENCES `guacamole_connection` (`connection_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of connection permissions. Each connection permission grants a user
-- specific access to a connection.
--

CREATE TABLE `guacamole_connection_permission` (

  `user_id`       int(11) NOT NULL,
  `connection_id` int(11) NOT NULL,
  `permission`    enum('READ',
                       'UPDATE',
                       'DELETE',
                       'ADMINISTER') NOT NULL,

  PRIMARY KEY (`user_id`,`connection_id`,`permission`),

  CONSTRAINT `guacamole_connection_permission_ibfk_1`
    FOREIGN KEY (`connection_id`)
    REFERENCES `guacamole_connection` (`connection_id`) ON DELETE CASCADE,

  CONSTRAINT `guacamole_connection_permission_ibfk_2`
    FOREIGN KEY (`user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of connection group permissions. Each group permission grants a user
-- specific access to a connection group.
--

CREATE TABLE `guacamole_connection_group_permission` (

  `user_id`             int(11) NOT NULL,
  `connection_group_id` int(11) NOT NULL,
  `permission`          enum('READ',
                             'UPDATE',
                             'DELETE',
                             'ADMINISTER') NOT NULL,

  PRIMARY KEY (`user_id`,`connection_group_id`,`permission`),

  CONSTRAINT `guacamole_connection_group_permission_ibfk_1`
    FOREIGN KEY (`connection_group_id`)
    REFERENCES `guacamole_connection_group` (`connection_group_id`) ON DELETE CASCADE,

  CONSTRAINT `guacamole_connection_group_permission_ibfk_2`
    FOREIGN KEY (`user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of system permissions. Each system permission grants a user a
-- system-level privilege of some kind.
--

CREATE TABLE `guacamole_system_permission` (

  `user_id`    int(11) NOT NULL,
  `permission` enum('CREATE_CONNECTION',
		    'CREATE_CONNECTION_GROUP',
                    'CREATE_USER',
                    'ADMINISTER') NOT NULL,

  PRIMARY KEY (`user_id`,`permission`),

  CONSTRAINT `guacamole_system_permission_ibfk_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of user permissions. Each user permission grants a user access to
-- another user (the "affected" user) for a specific type of operation.
--

CREATE TABLE `guacamole_user_permission` (

  `user_id`          int(11) NOT NULL,
  `affected_user_id` int(11) NOT NULL,
  `permission`       enum('READ',
                          'UPDATE',
                          'DELETE',
                          'ADMINISTER') NOT NULL,

  PRIMARY KEY (`user_id`,`affected_user_id`,`permission`),

  CONSTRAINT `guacamole_user_permission_ibfk_1`
    FOREIGN KEY (`affected_user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE,

  CONSTRAINT `guacamole_user_permission_ibfk_2`
    FOREIGN KEY (`user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table of connection history records. Each record defines a specific user's
-- session, including the connection used, the start time, and the end time
-- (if any).
--

CREATE TABLE `guacamole_connection_history` (

  `history_id`    int(11)  NOT NULL AUTO_INCREMENT,
  `user_id`       int(11)  NOT NULL,
  `connection_id` int(11)  NOT NULL,
  `start_date`    datetime NOT NULL,
  `end_date`      datetime DEFAULT NULL,

  PRIMARY KEY (`history_id`),
  KEY `user_id` (`user_id`),
  KEY `connection_id` (`connection_id`),
  KEY `start_date` (`start_date`),
  KEY `end_date` (`end_date`),

  CONSTRAINT `guacamole_connection_history_ibfk_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `guacamole_user` (`user_id`) ON DELETE CASCADE,

  CONSTRAINT `guacamole_connection_history_ibfk_2`
    FOREIGN KEY (`connection_id`)
    REFERENCES `guacamole_connection` (`connection_id`) ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

