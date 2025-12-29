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


  property Process getFanState: Process {
    id: getFanStateProcess
    command: ["fan_state", "get-int"]
    running: false

    stdout: StdioCollector {
      id: stdoutCollector
    }

    onExited: function (exitCode, exitStatus) {
      if (exitCode === 0) {
        const output = parseInt(stdoutCollector.text.trim());
        if (!isNaN(output)) {
          root.fanState = output;
        }
      } else {
        Logger.e("ASUS Fan State", `Failed to get fan state`);
      }
    }
  }

  Component.onCompleted: {
    getFanStateProcess.running = true;
  }

  function setFanState(value) {
    Quickshell.execDetached(["fan_state", "set", value]);
    getFanStateProcess.running = true;
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
  tooltipDirection: BarService.getTooltipDirection()
  baseSize: Style.capsuleHeight
  applyUiScale: false
  density: Settings.data.bar.density
  customRadius: Style.radiusL
  colorBg: Style.capsuleColor
  colorFg: getColor()
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  onClicked: {
    setFanState((fanState + 1) % 4);
  }
}
