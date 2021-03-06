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

var Guacamole = Guacamole || {};

/**
 * A writer which automatically writes to the given output stream with arbitrary
 * binary data, supplied as ArrayBuffers.
 * 
 * @constructor
 * @param {Guacamole.OutputStream} stream The stream that data will be written
 *                                        to.
 */
Guacamole.ArrayBufferWriter = function(stream) {

    /**
     * Reference to this Guacamole.StringWriter.
     * @private
     */
    var guac_writer = this;

    // Simply call onack for acknowledgements
    stream.onack = function(status) {
        if (guac_writer.onack)
            guac_writer.onack(status);
    };

    /**
     * Encodes the given data as base64, sending it as a blob. The data must
     * be small enough to fit into a single blob instruction.
     * 
     * @private
     * @param {Uint8Array} bytes The data to send.
     */
    function __send_blob(bytes) {

        var binary = "";

        // Produce binary string from bytes in buffer
        for (var i=0; i<bytes.byteLength; i++)
            binary += String.fromCharCode(bytes[i]);

        // Send as base64
        stream.sendBlob(window.btoa(binary));

    }

    /**
     * Sends the given data.
     * 
     * @param {ArrayBuffer|TypedArray} data The data to send.
     */
    this.sendData = function(data) {

        var bytes = new Uint8Array(data);

        // If small enough to fit into single instruction, send as-is
        if (bytes.length <= 6048)
            __send_blob(bytes);

        // Otherwise, send as multiple instructions
        else {
            for (var offset=0; offset<bytes.length; offset += 6048)
                __send_blob(bytes.subarray(offset, offset + 6048));
        }

    };

    /**
     * Signals that no further text will be sent, effectively closing the
     * stream.
     */
    this.sendEnd = function() {
        stream.sendEnd();
    };

    /**
     * Fired for received data, if acknowledged by the server.
     * @event
     * @param {Guacamole.Status} status The status of the operation.
     */
    this.onack = null;

};