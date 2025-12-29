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

  signal fanStateChanged(int newFanState)

  property Process getFanState: Process {
    id: getFanState
    command: ["fan_state", "get_int"]
    running: false

    stdout: StdioCollector {
      id: stdoutCollector
    }
  }

  function setFanState(newFanState) {
      Quickshell.execDetached(["fan_state", "set", newFanState])
      fanStateChanged(newFanState)
  }

  function fanStateString() {
      switch (fanState) {
          case 0: return pluginApi?.tr("tooltip.standard") || "Standard"
          case 1: return pluginApi?.tr("tooltip.quiet") || "Quiet"
          case 2: return pluginApi?.tr("tooltip.high") || "High-Performance"
          case 3: return pluginApi?.tr("tooltip.full") || "Full-Performance"
          default: return pluginApi?.tr("tooltip.unknown") || "Unknown"
      }
  }
  
  function fanStateIcon() {
      switch (fanState) {
          case 0: return "car-fan"
          case 1: return "car-fan-1"
          case 2: return "car-fan-2"
          case 3: return "car-fan-3"
          default: return "car-fan"
      }
  }

  icon: fanStateIcon()
  tooltipText: fanStateString()
  tooltipDirection: BarService.getTooltipDirection()
  baseSize: Style.capsuleHeight
  applyUiScale: false
  density: Settings.data.bar.density
  customRadius: Style.radiusL
  colorBg: Style.capsuleColor
  colorFg: Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  onClicked: {
      setFanState((fanState + 1) % 4)
  }
}
