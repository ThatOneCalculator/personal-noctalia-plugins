import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

// Bar Widget Component
NIconButton {
  id: root

  property var pluginApi: null
  property int fanState: -1

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property string tooltipDirection: BarService.getTooltipDirection()
  property string density: Settings.data.bar.density

  Component.onCompleted: {
    if (pluginApi?.mainInstance) {
      root.fanState = pluginApi.mainInstance.fanState;
      pluginApi.mainInstance.refreshFanState();
    }
  }

  onPluginApiChanged: {
    if (pluginApi?.mainInstance) {
      root.fanState = pluginApi.mainInstance.fanState;
    }
  }

  Connections {
    target: pluginApi?.mainInstance ?? null

    function onFanStateChanged() {
      Logger.i("ASUS Fan State Widget", `onFanStateChanged called, target: ${target}, new fanState: ${target?.fanState}`);
      if (target) {
        root.fanState = target.fanState;
      }
    }
  }

  function setFanState(value) {
    Logger.i("ASUS Fan State Widget", `setFanState called with value ${value}, pluginApi.mainInstance: ${pluginApi?.mainInstance}`);
    if (pluginApi?.mainInstance) {
      pluginApi.mainInstance.setFanState(value);
    }
  }

  function getTooltip() {
    switch (fanState) {
    case 0:
      return pluginApi?.tr("tooltip.standard") || "Standard";
    case 1:
      return pluginApi?.tr("tooltip.quiet") || "Quiet";
    case 2:
      return pluginApi?.tr("tooltip.high") || "High-Performance";
    case 3:
      return pluginApi?.tr("tooltip.full") || "Full-Performance";
    default:
      return pluginApi?.tr("tooltip.unknown") || "Unknown";
    }
  }

  function getIcon() {
    switch (fanState) {
    case 0:
      return "car-fan";
    case 1:
      return "car-fan-1";
    case 2:
      return "car-fan-2";
    case 3:
      return "car-fan-3";
    default:
      return "car-fan";
    }
  }

  function getColor() {
    switch (fanState) {
    case 3:
      return Color.mPrimary;
    case 2:
      return "#c4a7e7";
    case 1:
      return Color.mSecondary;
    case 0:
      return Color.mOnSurface;
    default:
      return Color.mOnSurface;
    }
  }

  icon: getIcon()
  tooltipText: getTooltip()
  baseSize: Style.capsuleHeight
  applyUiScale: false
  customRadius: Style.radiusL
  colorBg: Style.capsuleColor
  colorFg: getColor()
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  onClicked: {
    Logger.i("ASUS Fan State Widget", `Clicked, current fanState: ${fanState}`);
    setFanState((fanState + 1) % 4);
  }
}
