/*
 *      Copyright (C) 2017 Team XBMC
 *      http://xbmc.org
 *
 *  This Program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2, or (at your option)
 *  any later version.
 *
 *  This Program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with XBMC; see the file COPYING.  If not, see
 *  <http://www.gnu.org/licenses/>.
 *
 */

#include "Connection.h"

#include <cassert>
#include <map>

#include "utils/log.h"

using namespace KODI::WINDOWING::WAYLAND;

namespace
{

void Bind(wayland::registry_t& registry, wayland::proxy_t& target, std::uint32_t name, std::string const& interface, std::uint32_t bindVersion, std::uint32_t offeredVersion)
{
  CLog::Log(LOGDEBUG, "Binding Wayland protocol %s version %u (server has version %u)", interface.c_str(), bindVersion, offeredVersion);
  registry.bind(name, target, bindVersion);
}

}

CConnection::CConnection(IConnectionHandler* handler)
: m_handler(handler)
{
  m_display.reset(new wayland::display_t);
  m_registry = m_display->get_registry();
  
  m_binds = {
    { wayland::compositor_t::interface_name, { m_compositor, 3 } },
    { wayland::shell_t::interface_name, { m_shell, 1 } },
    { wayland::shm_t::interface_name, { m_shm, 1 } }
  };

  HandleRegistry();
  
  CLog::Log(LOGDEBUG, "Wayland connection: Waiting for global interfaces");
  if (m_display->roundtrip() < 0)
  {
    throw std::runtime_error("Wayland roundtrip failed");
  }
  CLog::Log(LOGDEBUG, "Wayland connection: Initial roundtrip complete");
  
  CheckRequiredGlobals();
}

void CConnection::HandleRegistry()
{
  m_registry.on_global() = [this] (std::uint32_t name, std::string interface, std::uint32_t version)
  { 
    auto it = m_binds.find(interface);
    if (it != m_binds.end())
    {
      Bind(m_registry, it->second.target, name, interface, it->second.bindVersion, version);
    }
    else if (interface == wayland::seat_t::interface_name)
    {
      wayland::seat_t seat;
      Bind(m_registry, seat, name, interface, 5, version);
      m_handler->OnSeatAdded(name, seat);
    }
    else if (interface == wayland::output_t::interface_name)
    {
      wayland::output_t output;
      Bind(m_registry, output, name, interface, 2, version);
      m_handler->OnOutputAdded(name, output);
    }
  };
  m_registry.on_global_remove() = [this] (std::uint32_t name)
  {
    m_handler->OnGlobalRemoved(name);
  };
}

void CConnection::CheckRequiredGlobals()
{
  for (auto const& bind : m_binds)
  {
    if (bind.second.required && !bind.second.target)
    {
      throw std::runtime_error(std::string("Missing required ") + bind.first + " protocol");
    }
  }
}

wayland::display_t& CConnection::GetDisplay()
{
  assert(m_display);
  return *m_display;
}

wayland::compositor_t& CConnection::GetCompositor()
{
  assert(m_compositor);
  return m_compositor;
}

wayland::shell_t& CConnection::GetShell()
{
  assert(m_shell);
  return m_shell;
}

wayland::shm_t& CConnection::GetShm()
{
  assert(m_shm);
  return m_shm;
}
