# -*- coding: utf-8 -*-
<%doc>
 *
 *   LinOTP - the open source solution for two factor authentication
 *   Copyright (C) 2010 - 2014 LSE Leading Security Experts GmbH
 *
 *   This file is part of LinOTP server.
 *
 *   This program is free software: you can redistribute it and/or
 *   modify it under the terms of the GNU Affero General Public
 *   License, version 3, as published by the Free Software Foundation.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the
 *              GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *    E-mail: linotp@lsexperts.de
 *    Contact: www.linotp.org
 *    Support: www.lsexperts.de
 *
 * contains the motp token web interface
</%doc>



%if c.scope == 'config.title' :
    ${_("mOTP Token Settings")}
%endif

%if c.scope == 'config' :
%endif

%if c.scope == 'enroll.title' :
    ${_("mOTP - mobile otp")}
%endif

%if c.scope == 'enroll' :
    <script>
    /*
     * 'typ'_enroll_setup_defaults()
     *
     * this method is called, before the dialog is shown
     *
     */
    function motp_enroll_setup_defaults(config, options){
        var rand_pin = options['otp_pin_random'];
        if (rand_pin > 0) {
            $("[name='set_pin_rows']").hide();
        } else {
            $("[name='set_pin_rows']").show();
        }
        
    }    
    /*
    * 'typ'_get_enroll_params()
    *
    * this method is called, when the token  is submitted
    * - it will return a hash of parameters for admin/init call
    *
    */
    function motp_get_enroll_params(){
        var url = {};
        url['type'] = 'motp';
        url['description'] = $('#enroll_motp_desc').val();

        url['otpkey']   = $('#motp_initsecret').val();
        url['otppin']   = $('#motp_pin1').val();
        jQuery.extend(url, add_user_data());

        if ($('#motp_tokenpin1').val() != '') {
            url['pin'] = $('#motp_tokenpin1').val();
        }

        return url;
    }
    </script>
    <hr>
    <p>${_("Please enter or copy the init-secret, that was generated by your app and the PIN you are using on your phone.")}</p>
    <table>
        <tr>
            <td>
                <label for="motp_initsecret">${_("Init secret")}</label>
            </td>
            <td>
                <input type="text" name="motp_initsecret" id="motp_initsecret" value="" class="text ui-widget-content ui-corner-all" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="motp_pin1">mOTP PIN</label>
            </td>
            <td>
                <input onkeyup="checkpins('motp_pin1','motp_pin2');" autocomplete="off" type="password" name="motp_pin1" id="motp_pin1" value="" class="text ui-widget-content ui-corner-all" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="motp_pin2">${_("(again)")}</label>
            </td>
            <td>
                <input onkeyup="checkpins('motp_pin1','motp_pin2');" autocomplete="off" type="password" name="motp_pin2" id="motp_pin2" value="" class="text ui-widget-content ui-corner-all" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="enroll_motp_desc" id="enroll_motp_desc_label">${_("Description")}</label>
            </td>
            <td>
                <input type="text" name="enroll_motp_desc" id="enroll_motp_desc" value="webGUI_generated" class="text" />
            </td>
        </tr>

        <tr name="set_pin_rows" class="space" title='${_("Protect your token with a static pin")}'><th colspan="2">${_("Token Pin:")}</th></tr>
        <tr name='set_pin_rows'>
            <td class="description"><label for="motp_tokenpin1" id="motp_tokenpin1_label">${_("enter PIN")}:</label></td>
            <td><input type="password" autocomplete="off" onkeyup="checkpins('motp_tokenpin1','motp_tokenpin2');" name="pin1" id="motp_tokenpin1"
                    class="text ui-widget-content ui-corner-all" /></td>
        </tr>
        <tr name='set_pin_rows'>
            <td class="description"><label for="motp_tokenpin2" id="motp_tokenpin2_label">${_("confirm PIN")}:</label></td>
            <td><input type="password" autocomplete="off" onkeyup="checkpins('motp_tokenpin1','motp_tokenpin2');" name="pin2" id="motp_tokenpin2"
                    class="text ui-widget-content ui-corner-all" /></td
        </tr>
    </table>
% endif

%if c.scope == 'selfservice.title.enroll':
    ${_("Register mOTP")}
%endif

%if c.scope == 'selfservice.enroll':
    <script>
        jQuery.extend(jQuery.validator.messages, {
            required:  "${_('required input field')}",
            minlength: "${_('minimum length must be greater than {0}')}",
            maxlength: "${_('maximum length must be lower than {0}')}",
        });
        jQuery.validator.addMethod("motp_secret_v", function(value, element, param){
            return value.match(/^[a-fA-F0-9]+$/i);
        }, '${_("Please enter a valid init secret. It may only contain numbers and the letters A-F.")}' );
        $('#form_registermotp').validate({
            rules: {
                motp_secret: {
                    required: true,
                    minlength: 16,
                    maxlength: 32,
                    number: false,
                    motp_secret_v: true
                }
            }
        });
        $('#form_registermotp').submit(function( submit_event ) {
            submit_event.preventDefault();
            if ($(this).valid()) {
                var params = self_motp_get_param();
                enroll_token( params );
                $(this).trigger("reset"); //clear form
            } else {
                alert('${_("Form data not valid.")}');
            }
        });

        function self_motp_get_param()
        {
            var urlparam = {};
            urlparam['type']        = 'motp';
            urlparam['description'] = $("#motp_self_desc").val();
            urlparam['otpkey']      = $('#motp_secret').val();
            urlparam['otppin']      = $('#motp_s_pin1').val();
            return urlparam;
        }
    </script>

    <h1>${_("Register your mOTP Token")}</h1>
    <div id="registermotpform">
        <form class="cmxform" id="form_registermotp" method="post">
            <fieldset>
                <table>
                    <tr>
                        <td>
                            <label for="motp_secret">${_("Init Secret of motp-Token")}</label>
                        </td>
                        <td>
                            <input id="motp_secret" name="motp_secret" class="required ui-widget-content ui-corner-all" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="motp_s_pin1">${_("mOTP PIN")}</label>
                        </td>
                        <td>
                            <input autocomplete="off" type="password" onkeyup="checkpins('motp_s_pin1', 'motp_s_pin2');" id="motp_s_pin1" class="required text ui-widget-content ui-corner-all" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="motp_s_pin2">${_("mOTP PIN (again)")}</label>
                        </td>
                        <td>
                            <input autocomplete="off" type="password" onkeyup="checkpins('motp_s_pin1', 'motp_s_pin2');" id="motp_s_pin2" class="required text ui-widget-content ui-corner-all" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="motp_self_desc" id="motp_self_desc_label">${_("Description")}</label>
                        </td>
                        <td>
                            <input type="text" name="motp_self_desc" id="motp_self_desc" value="self enrolled" class="text" />
                        </td>
                    </tr>
                </table>
                <input type="submit" class="action-button" id="button_register_motp"
                    value="${_("register mOTP Token")}" />
            </fieldset>
        </form>
    </div>
% endif
