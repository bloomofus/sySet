#!/usr/bin/env python3

import os
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib

HOME = os.path.expanduser("~")
APP_DIR = os.path.join(HOME, ".local", "share", "applications")

class DesktopCreatorApp:
    def __init__(self):
        self.exec_path = ""
        self.icon_path = ""

        self.builder = Gtk.Builder()
        self.window = Gtk.Window(title="Desktop Entry Creator")
        self.window.set_default_size(600, 500)
        self.window.connect("destroy", Gtk.main_quit)

        # 布局
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        vbox.set_margin_top(10)
        vbox.set_margin_bottom(10)
        vbox.set_margin_start(10)
        vbox.set_margin_end(10)
        self.window.add(vbox)

        # 选择可执行文件
        hbox_exec = Gtk.Box(spacing=10)
        self.exec_button = Gtk.Button(label="选择可执行程序")
        self.exec_button.connect("clicked", self.on_choose_exec)
        self.exec_label = Gtk.Label(label="未选择", xalign=0)
        hbox_exec.pack_start(self.exec_button, False, False, 0)
        hbox_exec.pack_start(self.exec_label, True, True, 0)
        vbox.pack_start(hbox_exec, False, False, 0)

        # 选择图标
        hbox_icon = Gtk.Box(spacing=10)
        self.icon_button = Gtk.Button(label="选择图标")
        self.icon_button.connect("clicked", self.on_choose_icon)
        self.icon_label = Gtk.Label(label="未选择", xalign=0)
        hbox_icon.pack_start(self.icon_button, False, False, 0)
        hbox_icon.pack_start(self.icon_label, True, True, 0)
        vbox.pack_start(hbox_icon, False, False, 0)

        # 预览/编辑区域
        self.textview = Gtk.TextView()
        self.textbuffer = self.textview.get_buffer()
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        scrolled.add(self.textview)
        vbox.pack_start(scrolled, True, True, 0)

        # 生成按钮
        self.generate_button = Gtk.Button(label="生成 .desktop 文件")
        self.generate_button.connect("clicked", self.on_generate)
        self.generate_button.set_sensitive(False)
        vbox.pack_start(self.generate_button, False, False, 0)

        self.window.show_all()

    def on_choose_exec(self, button):
        dialog = Gtk.FileChooserDialog(
            title="选择可执行程序",
            parent=self.window,
            action=Gtk.FileChooserAction.OPEN,
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN, Gtk.ResponseType.OK
        )
        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.exec_path = dialog.get_filename()
            self.exec_label.set_text(self.exec_path)
            self.update_preview()
            self.generate_button.set_sensitive(True)
        dialog.destroy()

    def on_choose_icon(self, button):
        dialog = Gtk.FileChooserDialog(
            title="选择图标",
            parent=self.window,
            action=Gtk.FileChooserAction.OPEN,
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN, Gtk.ResponseType.OK
        )
        # 添加图标文件过滤器
        filter_img = Gtk.FileFilter()
        filter_img.set_name("图像文件")
        for ext in ["*.png", "*.svg", "*.xpm", "*.ico"]:
            filter_img.add_pattern(ext)
        dialog.add_filter(filter_img)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.icon_path = dialog.get_filename()
            self.icon_label.set_text(self.icon_path)
            self.update_preview()
        dialog.destroy()

    def update_preview(self):
        name = os.path.basename(self.exec_path) if self.exec_path else "MyApp"
        exec_path = self.exec_path if self.exec_path else "/path/to/executable"
        icon_path = self.icon_path if self.icon_path else "/path/to/icon.png"

        desktop_content = f"""[Desktop Entry]
Version=1.0
Type=Application
Name={name}
Comment=Custom application launcher
Exec={exec_path}
Icon={icon_path}
Terminal=false
Categories=Utility;
"""
        self.textbuffer.set_text(desktop_content)

    def on_generate(self, button):
        start, end = self.textbuffer.get_bounds()
        content = self.textbuffer.get_text(start, end, True)

        # 默认保存路径
        suggested_name = "myapp.desktop"
        if self.exec_path:
            base = os.path.basename(self.exec_path)
            suggested_name = base + ".desktop"

        dialog = Gtk.FileChooserDialog(
            title="保存 .desktop 文件",
            parent=self.window,
            action=Gtk.FileChooserAction.SAVE,
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_SAVE, Gtk.ResponseType.OK
        )
        dialog.set_current_folder(APP_DIR)
        dialog.set_current_name(suggested_name)
        dialog.set_do_overwrite_confirmation(True)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            filepath = dialog.get_filename()
            if not filepath.endswith(".desktop"):
                filepath += ".desktop"
            try:
                with open(filepath, "w") as f:
                    f.write(content)
                # 设置可执行权限
                os.chmod(filepath, 0o755)
                dialog2 = Gtk.MessageDialog(
                    parent=self.window,
                    message_type=Gtk.MessageType.INFO,
                    buttons=Gtk.ButtonsType.OK,
                    text="快捷方式已生成！"
                )
                dialog2.run()
                dialog2.destroy()
            except Exception as e:
                dialog2 = Gtk.MessageDialog(
                    parent=self.window,
                    message_type=Gtk.MessageType.ERROR,
                    buttons=Gtk.ButtonsType.OK,
                    text=f"保存失败：{e}"
                )
                dialog2.run()
                dialog2.destroy()
        dialog.destroy()

if __name__ == "__main__":
    app = DesktopCreatorApp()
    Gtk.main()
