/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.guacamole.auth.jdbc.connectiongroup;

import org.apache.guacamole.auth.jdbc.base.GroupedObjectModel;
import org.apache.guacamole.net.auth.ConnectionGroup;

/**
 * Object representation of a Guacamole connection group, as represented in the
 * database.
 *
 * @author Michael Jumper
 */
public class ConnectionGroupModel extends GroupedObjectModel {

    /**
     * The human-readable name associated with this connection group.
     */
    private String name;

    /**
     * The type of this connection group, such as organizational or balancing.
     */
    private ConnectionGroup.Type type;

    /**
     * The maximum number of connections that can be established to this
     * connection group concurrently, zero if no restriction applies, or
     * null if the default restrictions should be applied.
     */
    private Integer maxConnections;

    /**
     * The maximum number of connections that can be established to this
     * connection group concurrently by any one user, zero if no restriction
     * applies, or null if the default restrictions should be applied.
     */
    private Integer maxConnectionsPerUser;

    /**
     * Creates a new, empty connection group.
     */
    public ConnectionGroupModel() {
    }

    /**
     * Returns the name associated with this connection group.
     *
     * @return
     *     The name associated with this connection group.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name associated with this connection group.
     *
     * @param name
     *     The name to associate with this connection group.
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Returns the type of this connection group, such as organizational or
     * balancing.
     *
     * @return
     *     The type of this connection group.
     */
    public ConnectionGroup.Type getType() {
        return type;
    }

    /**
     * Sets the type of this connection group, such as organizational or
     * balancing.
     *
     * @param type
     *     The type of this connection group.
     */
    public void setType(ConnectionGroup.Type type) {
        this.type = type;
    }

    /**
     * Returns the maximum number of connections that can be established to
     * this connection group concurrently.
     *
     * @return
     *     The maximum number of connections that can be established to this
     *     connection group concurrently, zero if no restriction applies, or
     *     null if the default restrictions should be applied.
     */
    public Integer getMaxConnections() {
        return maxConnections;
    }

    /**
     * Sets the maximum number of connections that can be established to this
     * connection group concurrently.
     *
     * @param maxConnections
     *     The maximum number of connections that can be established to this
     *     connection group concurrently, zero if no restriction applies, or
     *     null if the default restrictions should be applied.
     */
    public void setMaxConnections(Integer maxConnections) {
        this.maxConnections = maxConnections;
    }

    /**
     * Returns the maximum number of connections that can be established to
     * this connection group concurrently by any one user.
     *
     * @return
     *     The maximum number of connections that can be established to this
     *     connection group concurrently by any one user, zero if no
     *     restriction applies, or null if the default restrictions should be
     *     applied.
     */
    public Integer getMaxConnectionsPerUser() {
        return maxConnectionsPerUser;
    }

    /**
     * Sets the maximum number of connections that can be established to this
     * connection group concurrently by any one user.
     *
     * @param maxConnectionsPerUser
     *     The maximum number of connections that can be established to this
     *     connection group concurrently by any one user, zero if no
     *     restriction applies, or null if the default restrictions should be
     *     applied.
     */
    public void setMaxConnectionsPerUser(Integer maxConnectionsPerUser) {
        this.maxConnectionsPerUser = maxConnectionsPerUser;
    }

    @Override
    public String getIdentifier() {

        // If no associated ID, then no associated identifier
        Integer id = getObjectID();
        if (id == null)
            return null;

        // Otherwise, the identifier is the ID as a string
        return id.toString();

    }

    @Override
    public void setIdentifier(String identifier) {
        throw new UnsupportedOperationException("Connection group identifiers are derived from IDs. They cannot be set.");
    }

}
