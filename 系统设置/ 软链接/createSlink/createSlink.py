#!/usr/bin/env python3

import os
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

HOME = os.path.expanduser("~")

class SymlinkCreatorApp:
    def __init__(self):
        self.target_path = ""
        self.link_path = ""

        self.builder = Gtk.Builder()
        self.window = Gtk.Window(title="软链接创建器")
        self.window.set_default_size(600, 250)
        self.window.connect("destroy", Gtk.main_quit)

        # 布局
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        vbox.set_margin_top(10)
        vbox.set_margin_bottom(10)
        vbox.set_margin_start(10)
        vbox.set_margin_end(10)
        self.window.add(vbox)

        # 选择目标路径（要链接的文件/目录）
        hbox_target = Gtk.Box(spacing=10)
        self.target_button = Gtk.Button(label="选择目标路径")
        self.target_button.connect("clicked", self.on_choose_target)
        self.target_label = Gtk.Label(label="未选择", xalign=0)
        hbox_target.pack_start(self.target_button, False, False, 0)
        hbox_target.pack_start(self.target_label, True, True, 0)
        vbox.pack_start(hbox_target, False, False, 0)

        # 选择链接位置（软链接存放位置）
        hbox_link = Gtk.Box(spacing=10)
        self.link_button = Gtk.Button(label="选择链接位置")
        self.link_button.connect("clicked", self.on_choose_link)
        self.link_label = Gtk.Label(label="未选择", xalign=0)
        hbox_link.pack_start(self.link_button, False, False, 0)
        hbox_link.pack_start(self.link_label, True, True, 0)
        vbox.pack_start(hbox_link, False, False, 0)

        # 创建按钮
        self.create_button = Gtk.Button(label="创建软链接")
        self.create_button.connect("clicked", self.on_create_symlink)
        self.create_button.set_sensitive(False)
        vbox.pack_start(self.create_button, False, False, 0)

        self.window.show_all()

    def on_choose_target(self, button):
        dialog = Gtk.FileChooserDialog(
            title="选择要链接的目标（文件或文件夹）",
            parent=self.window,
            action=Gtk.FileChooserAction.OPEN,
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN, Gtk.ResponseType.OK
        )
        dialog.set_select_multiple(False)
        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.target_path = dialog.get_filename()
            self.target_label.set_text(self.target_path)
            self.update_button_state()
        dialog.destroy()

    def on_choose_link(self, button):
        dialog = Gtk.FileChooserDialog(
            title="选择软链接保存位置（可指定文件名）",
            parent=self.window,
            action=Gtk.FileChooserAction.SAVE,
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.STOCK_SAVE, Gtk.ResponseType.OK
        )
        dialog.set_do_overwrite_confirmation(True)
        # 默认建议名称
        if self.target_path:
            suggested = os.path.basename(self.target_path) + "_link"
            dialog.set_current_name(suggested)
        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.link_path = dialog.get_filename()
            self.link_label.set_text(self.link_path)
            self.update_button_state()
        dialog.destroy()

    def update_button_state(self):
        self.create_button.set_sensitive(bool(self.target_path and self.link_path))

    def on_create_symlink(self, button):
        try:
            # 如果用户指定了文件夹作为 link_path，但未给文件名，我们可以自动追加目标 basename
            if os.path.isdir(self.link_path):
                link_name = os.path.join(self.link_path, os.path.basename(self.target_path))
            else:
                link_name = self.link_path

            # 确保父目录存在
            link_dir = os.path.dirname(link_name)
            os.makedirs(link_dir, exist_ok=True)

            # 创建软链接
            os.symlink(self.target_path, link_name)

            dialog = Gtk.MessageDialog(
                parent=self.window,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.OK,
                text=f"软链接已创建！\n{link_name} → {self.target_path}"
            )
            dialog.run()
            dialog.destroy()

        except Exception as e:
            dialog = Gtk.MessageDialog(
                parent=self.window,
                message_type=Gtk.MessageType.ERROR,
                buttons=Gtk.ButtonsType.OK,
                text=f"创建失败：{e}"
            )
            dialog.run()
            dialog.destroy()

if __name__ == "__main__":
    app = SymlinkCreatorApp()
    Gtk.main()