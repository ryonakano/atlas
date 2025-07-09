/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Define {
    /**
     * String representation of Adw.ColorScheme.
     *
     * Note: Only defines necessary strings for the app.
     */
    namespace ColorScheme {
        /** Inherit the parent color-scheme. */
        public const string DEFAULT = "default";
        /** Always use light appearance. */
        public const string FORCE_LIGHT = "force-light";
        /** Always use dark appearance. */
        public const string FORCE_DARK = "force-dark";
    }

    namespace MapSource {
        public const string MAPNIK = "mapnik";
        public const string TRANSPORT = "transport";
    }
}
